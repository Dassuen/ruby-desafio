# Desafio Customer Success Balancing

Este é um desafio de programação que envolve a distribuição de clientes entre Customer Successes (CS) com base em seus scores.
Pode ser testado pelo link: https://replit.com/@DassuenCabral/Desafio-SEA-Tecnologia#main.rb

## Descrição

O desafio consiste em implementar a lógica para distribuir clientes entre os CSs disponíveis, levando em consideração os seguintes critérios:

- Cada cliente deve ser atribuído ao CS com o score mais próximo ou igual ao seu.
- Alguns CSs podem estar ausentes ou indisponíveis e não devem ser considerados para atribuição de clientes.
- Se dois ou mais CSs tiverem o mesmo número máximo de clientes, nenhum CS deve ser atribuído e o resultado deve ser 0.


## Observações:
- Todos os CSs têm níveis diferentes
- Não há limite de clientes por CS
- Um cliente pode ficar sem ser atendido
- Clientes podem ter o mesmo tamanho
- 0 < n < 1.000
- 0 < m < 1.000.000
- 0 < id_cs < 1.000
- 0 < id_cliente < 1.000.000
- 0 < nivel_cs < 10.000
- 0 < tamanho_cliente < 100.000
- Valor máximo de t = n/2 arrendondado para baixo
