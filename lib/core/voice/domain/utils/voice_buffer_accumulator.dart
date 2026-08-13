import 'dart:math' as math;

class VoiceBufferAccumulator {
  final List<String> _confirmedChunks = [];
  String _activeChunk = '';

  String get fullText {
    if (_confirmedChunks.isEmpty) return _activeChunk;
    if (_activeChunk.isEmpty) return _confirmedChunks.join(' ');
    return '${_confirmedChunks.join(' ')} $_activeChunk';
  }

  void onNewText(String newText, bool isFinal) {
    newText = newText.trim();
    if (newText.isEmpty) return;

    if (isFinal) {
      _commit(newText);
      return;
    }

    if (_activeChunk.isEmpty) {
      _activeChunk = newText;
      return;
    }

    if (_isNewChunk(newText)) {
      _commit(_activeChunk);
      _activeChunk = newText;
    } else {
      _activeChunk = newText;
    }
  }

  void _commit(String text) {
    if (text.isNotEmpty) {
      _confirmedChunks.add(text);
      _activeChunk = '';
    }
  }

  bool _isNewChunk(String newText) {
    int commonLen = 0;
    int minLen = math.min(_activeChunk.length, newText.length);
    for (int i = 0; i < minLen; i++) {
      if (_activeChunk[i] == newText[i]) {
        commonLen++;
      } else {
        break;
      }
    }
    // 如果連前兩個字都不一樣 (或長度不足但全不同)，代表 OS 已經清空緩衝區，這是一個全新的句子
    if (commonLen < 2 && _activeChunk.length >= 2) return true;
    if (commonLen == 0) return true;
    return false;
  }
}
