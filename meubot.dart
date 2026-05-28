import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

void main() async {
  // 1. Inicializa o DotEnv manualmente para evitar erro de "Undefined name"
  var envVars = DotEnv()..load(); 

  // 2. Tenta pegar o token
  final String? token = envVars['TELEGRAM_TOKEN'];

  if (token == null || token.isEmpty) {
    print('❌ ERRO: Token não encontrado no arquivo .env!');
    print('Certifique-se de que o arquivo .env tem a linha: TELEGRAM_TOKEN=seu_token_aqui');
    return;
  }

  print('🚀 Bot iniciado com sucesso...');

  int offset = 0;

  while (true) {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$token/getUpdates?offset=$offset');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        for (var update in data['result']) {
          offset = update['update_id'] + 1;

          if (update['message'] != null) {
            final message = update['message'];
            final chatId = message['chat']['id'];
            final texto = (message['text'] ?? '').toString().trim();

            print('📩 Mensagem recebida: $texto');

           if (texto == '/start') {
            await sendMessage(
              token,
              chatId,
              '👋 Seja Bem vindo(a) ao verificador de CPF!\n\nDigite seu CPF abaixo.\nEx: 000 000 000 00'
            );
          }
            else if (texto.isNotEmpty && !texto.startsWith('/')) {
              if (validarCPF(texto)) {
                await sendMessage(token, chatId, '✅ O CPF $texto é VÁLIDO!');
              } else {
                await sendMessage(token, chatId, '❌ O CPF $texto é INVÁLIDO!');
              }
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Erro: $e');
    }

    await Future.delayed(Duration(seconds: 2));
  }
}
