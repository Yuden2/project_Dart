import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final String token = '8734645709:AAGw7G2Y1dyP_zjmyWErG4yEHvh0QJAMg_M';
  final String baseUrl = 'https://api.telegram.org/bot$token';

  int lastUpdateId = 0;

  

  while (true) {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getUpdates?offset=${lastUpdateId + 1}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List updates = data['result'];

        for (var update in updates) {
          lastUpdateId = update['update_id'];
          final message = update['message'];

          if (message != null && message['text'] != null) {
            final int chatId = message['chat']['id'];
            final String texto = message['text'];

            

            print('Mensagem recebida: $texto'); 

             // 1. Verificação do comando /start
            if (texto == '/start') {
              String boasVindas = 'Olá, seja bem-vindo ao DartBot! 👋\n\n'
                  'Somos um verificador de CPF.\n'
                  'Por favor, digite seu CPF: (exemplo: 000.000.000-00)';
              
              await enviarMensagem(baseUrl, chatId, boasVindas);
            }

            // 2. Lógica de validação (só processa se NÃO for um comando)
            else if (!texto.startsWith('/')) {
              String resposta = validarCPF(texto) 
                  ? '✅ O CPF $texto é VÁLIDO!' 
                  : '❌ O CPF $texto é INVÁLIDO.';
              
              await enviarMensagem(baseUrl, chatId, resposta);
            }
          }
        }
      }
    } catch (e) {
      print('Erro na conexão: $e');
    }
    
    await Future.delayed(Duration(seconds: 1));
  }
}

// Função de envio manual via HTTP POST
Future<void> enviarMensagem(String baseUrl, int chatId, String texto) async {
  await http.post(
    Uri.parse('$baseUrl/sendMessage'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'chat_id': chatId,
      'text': texto,
    }),
  );
}

// Sua lógica de validação de CPF
bool validarCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  if (cpf.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
  List<int> numbers = cpf.split('').map((e) => int.parse(e)).toList();
  for (int j = 9; j <= 10; j++) {
    int sum = 0;
    for (int i = 0; i < j; i++) sum += numbers[i] * ((j + 1) - i);
    int res = (sum * 10) % 11;
    if (res == 10) res = 0;
    if (res != numbers[j]) return false;
  }
  return true;
}
