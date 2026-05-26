import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

void main() async {
  final String token = '8734645709:AAGw7G2Y1dyP_zjmyWErG4yEHvh0QJAMg_M';

  try {
    final botInfo = await Telegram(token).getMe();
    
    // Inicialização da versão 0.6.1
    var teledart = TeleDart(token, Event(botInfo.username!));

    teledart.start();
    print('🚀 BOT ONLINE: @${botInfo.username}');

    teledart.onMessage().listen((message) {
      final String texto = message.text ?? '';

      if (texto.isNotEmpty && !texto.startsWith('/')) {
        if (validarCPF(texto)) {
          // Na versão 0.6.1, o sendMessage é direto no teledart
          teledart.sendMessage(message.chat.id, '✅ O CPF $texto é VÁLIDO!');
        } else {
          teledart.sendMessage(message.chat.id, '❌ O CPF $texto é INVÁLIDO.');
        }
      }
    });
  } catch (e) {
    print('Erro ao iniciar o bot: $e');
  }
}

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
