require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
    def initialize(customer_success, customers, customer_success_away)
        @customer_success = customer_success
        @customers = customers
        @customer_success_away = customer_success_away
    end
    
    # Método que compara o score do cliente com o do cs
    # Retorna verdadeiro se score do cliente menor ou igual do cs
    def match_score(customer, cs)
        customer[:score] <= cs[:score]
    end
    
    #  Adiciona um cliente ao CS, inserindo na lista de clientes [:customers]
    def add_customer_to_cs(customer, cs)
        cs[:customers].push(customer)
    end
    
    # Retorna o número de clientes que um CS possui
    # acessando o atributo [:customers] do cs e retornando o tamanho
    def get_customers_number(cs)
        cs[:customers].length
    end
    
    # Método principal, executa a lógica para distrivuir clientes entre os CSs e retorna o id do CS com mais clientes
    # ou 0 se dois ou mais CSs tiverem o mesmo número de clientes
    def execute
        # Ordena o CSs pelo score em ordem crescente
        css_ordered_by_score = @customer_success.sort { |a,b| a[:score] <=> b[:score] }
        # Ordena os Clientes pelo score em ordem crescente
        customers_ordered_by_score = @customers.sort { |a,b| a[:score] <=> b[:score] }

        # Aqui é filtrada a lista de CSs disponíveis, excluindo aqueles que estão ausentes
        css_available = css_ordered_by_score.reject do |cs|
          @customer_success_away.any? { |cs_away| cs[:id] == cs_away}
        end
        # Mapeia os CSs disponiveis para um novo array css_with_customers
        # Onde cada CS tem uma lista vazia inicialmente
        css_with_customers = css_available.map do |cs|
          cs[:customers] = []
          cs
        end

        cs_index = 0

        # Loop que itera sobre cada cliente ordenado por score
        customers_ordered_by_score.each do |customer|
            cs = css_with_customers[cs_index]
            is_matched = match_score(customer, cs) 
            
            # Verifica se o cliente pode ser associado ao CS atual
            # Se puder associar ao CS, é adicionado e o próximo é verificado
            if is_matched
                add_customer_to_cs(customer, cs)
            next
        end
        # Se não puder ser associado ao CS
        # Busca o próximo CS disponível
        while !is_matched
            is_last_cs = css_with_customers.last == cs
            # Verifica se é o ultimo CS e encerra o loop caso seja
            if is_last_cs
              break
            end
            cs_index += 1
            cs = css_with_customers[cs_index]
            is_matched = match_score(customer, cs) # Se o score do cliente é compatível com o CS, adiciona
            add_customer_to_cs(customer, cs) if is_matched
            end
        end
        # Determina o CS com maior número de clientes
        css_with_most_customers = css_with_customers.reduce(css_with_customers[0]) do |overloaded_cs, cs|
          get_customers_number(cs) > get_customers_number(overloaded_cs) ? cs : overloaded_cs
        end
        # Verifica se há dois ou mais CSs com o mesmo número de clientes.
        same_clients_css = css_with_customers.any? do |cs|
          is_same_cs = cs[:id] == css_with_most_customers[:id]
          has_same_customers_number = get_customers_number(cs) == get_customers_number(css_with_most_customers)
          !is_same_cs && has_same_customers_number
        end
        # Se houver dois ou mais CSs com o mesmo número de clientes retorna 0
        # Senão retorna o ID do CSs com mais clientes
        same_clients_css ? 0 : css_with_most_customers[:id]
      
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
    def test_scenario_one
        css = [
            { id: 1, score: 60 }, 
            { id: 2, score: 20 }, 
            { id: 3, score: 95 }, 
            { id: 4, score: 75 }
        ]
        customers = [
            { id: 1, score: 90 }, 
            { id: 2, score: 20 }, 
            { id: 3, score: 70 }, 
            { id: 4, score: 40 }, 
            { id: 5, score: 60 }, 
            { id: 6, score: 10}]
        
        balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
        assert_equal 1, balancer.execute
    end

  def test_scenario_two
    css = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessBalancing.new(css, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    customer_success = Array.new(1000, 0)
    customer_success[998] = 100

    customers = Array.new(10000, 10)

    balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [1000])

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 999, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal balancer.execute, 1
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
    assert_equal balancer.execute, 0
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [4, 5, 6])
    assert_equal balancer.execute, 3
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end

Minitest.run
