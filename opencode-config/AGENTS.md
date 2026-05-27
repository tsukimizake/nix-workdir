人間の入力した命令に疑問点や曖昧な点がある場合は遠慮なく聞いてください。特に Wait, ... などと言いたくなったときはそうすべき可能性が高いです

## コーディングスタイル

### Elm
- 中身のない doc commentは書かないこと。コメントを書くなら「コードを読んでも分からないこと」(背景・意図・制約・落とし穴など) を書くべき。
- 複数回使わないものを別関数に分けたり let に切り出したりしないこと。とくに CSS スタイルは常に呼び出し箇所にインラインで書くこと。複数箇所で再利用するもののみ named 関数/let で抽出する。
- Palette.elm, Color.elmを利用しhexで色を直書きしないこと
- button_, linkButtonなどのPartsを利用し、通常のhtmlのformやbuttonなどをそのまま呼び出さないこと
- 縦方向にgapを取りたいだけの目的で `[ displayFlex, flexDirection column, rowGap _ ]` を書かないこと。`Css.Extra.verticalGapByMargin` を使う
