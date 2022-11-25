# frozen_string_literal: true

require 'kanakana/version'
require 'nkf'

# Kanakana
module Kanakana
  # p ("ｱ".."ﾜ").map{ |c| NKF.nkf("-Ww --hiragana", c) }.push("を", "ん")
  # 五十音
  HIRAGANA = %w[
    あ い う え お
    か き く け こ
    さ し す せ そ
    た ち つ て と
    な に ぬ ね の
    は ひ ふ へ ほ
    ま み む め も
    や ゆ よ
    ら り る れ ろ
    わ を ん
  ].freeze

  KATAKANA = %w[
    ア イ ウ エ オ
    カ キ ク ケ コ
    サ シ ス セ ソ
    タ チ ツ テ ト
    ナ ニ ヌ ネ ノ
    ハ ヒ フ ヘ ホ
    マ ミ ム メ モ
    ヤ ユ ヨ
    ラ リ ル レ ロ
    ワ ヲ ン
  ].freeze

  # DAKUON_BY_HIRAGANA
  # DAKUON_BY_SEION
  DAKUON_HIRAGANA = {
    'か' => 'が', 'き' => 'ぎ', 'く' => 'ぐ', 'け' => 'げ', 'こ' => 'ご',
    'さ' => 'ざ', 'し' => 'じ', 'す' => 'ず', 'せ' => 'ぜ', 'そ' => 'ぞ',
    'た' => 'だ', 'ち' => 'ぢ', 'つ' => 'づ', 'て' => 'で', 'と' => 'ど',
    'は' => 'ば', 'ひ' => 'び', 'ふ' => 'ぶ', 'へ' => 'べ', 'ほ' => 'ぼ',
    'う' => 'ゔ', 'ゝ' => 'ゞ'
  }.freeze
  DAKUTENABLE_HIRAGANA = DAKUON_HIRAGANA.keys

  DAKUON_KATAKANA = {
    'カ' => 'ガ', 'キ' => 'ギ', 'ク' => 'グ', 'ケ' => 'ゲ', 'コ' => 'ゴ',
    'サ' => 'ザ', 'シ' => 'ジ', 'ス' => 'ズ', 'セ' => 'ゼ', 'ソ' => 'ゾ',
    'タ' => 'ダ', 'チ' => 'ヂ', 'ツ' => 'ヅ', 'テ' => 'デ', 'ト' => 'ド',
    'ハ' => 'バ', 'ヒ' => 'ビ', 'フ' => 'ブ', 'ヘ' => 'ベ', 'ホ' => 'ボ',
    'ウ' => 'ヴ', 'ヽ' => 'ヾ',
    'ワ' => 'ヷ', 'ヰ' => 'ヸ', 'ヱ' => 'ヹ', 'ヲ' => 'ヺ'
  }.freeze
  DAKUTENABLE_KATAKANA = DAKUON_KATAKANA.keys

  DAKUON_TABLE = DAKUON_HIRAGANA.merge(DAKUON_KATAKANA)
  DAKUTENABLES = DAKUTENABLE_HIRAGANA + DAKUTENABLE_KATAKANA

  HANDAKUON_TABLE = {
    'は' => 'ぱ', 'ひ' => 'ぴ', 'ふ' => 'ぷ', 'へ' => 'ぺ', 'ほ' => 'ぽ',
    'ハ' => 'パ', 'ヒ' => 'ピ', 'フ' => 'プ', 'ヘ' => 'ペ', 'ホ' => 'ポ'
  }.freeze

  KOGAKI_HIRAGANA = {
    'ぁ' => 'あ', 'ぃ' => 'い', 'ぅ' => 'う', 'ぇ' => 'え', 'ぉ' => 'お',
    'ゕ' => 'か', 'ゖ' => 'け',
    'っ' => 'つ',
    'ゃ' => 'や', 'ゅ' => 'ゆ', 'ょ' => 'よ',
    'ゎ' => 'わ'
  }.freeze

  KOGAKI_KATAKANA = {
    'ァ' => 'ア', 'ィ' => 'イ', 'ゥ' => 'ウ', 'ェ' => 'エ', 'ォ' => 'オ',
    'ヵ' => 'カ', 'ヶ' => 'ケ',
    'ッ' => 'ツ',
    'ャ' => 'ヤ', 'ュ' => 'ユ', 'ョ' => 'ヨ',
    'ヮ' => 'ワ'
  }.freeze

  HIRAGANA_SMALL_LIST = KOGAKI_HIRAGANA.keys

  ITAIJI = {
    'ゐ' => 'い', 'ゑ' => 'え',
    'ヰ' => 'イ', 'ヱ' => 'エ', 'ヲ' => 'オ'
  }.freeze

  NOT_DAKUTENABLE_HIRAGANA = HIRAGANA - DAKUON_HIRAGANA.keys
  NOT_DAKUTENABLE_KATAKANA = KATAKANA - DAKUON_KATAKANA.keys
  NOT_DAKUTENABLES = NOT_DAKUTENABLE_HIRAGANA + NOT_DAKUTENABLE_KATAKANA

  class << self
    def nigorize(str)
      pattern = /[#{DAKUTENABLES.join}]/
      str.unicode_normalize.gsub(pattern, DAKUON_TABLE)
    end

    def hyper_nigorize(str)
      pattern = /([#{NOT_DAKUTENABLES.join}])/
      nigorize(str).gsub(pattern) { "#{Regexp.last_match(1)}\u3099" }
    end

    def hiraganize(str)
      NKF.nkf('-w --hiragana', str)
    end

    def katakanize(str)
      NKF.nkf('-w --katakana', str)
    end

    def make_ascii(str)
      # NKF.nkf('-m0Z1 -w', str)
      NKF.nkf('-m0Z1 -W -w', str)
      NKF.nkf('-Z1 -Ww', str)
      # str.tr("０-９ａ-ｚＡ-Ｚ．，＠−", "0-9a-zA-Z.,@-")
      # str.tr('！-～', '!-~')
      # str.tr('　-～', ' -~')
    end

    def unicodes(str)
      # str.unpack('U*').map { |c| "U+#{c.to_s(16).upcase}" }
      str.codepoints.map { |c| "U+#{c.to_s(16).upcase}" }
    end

    def escape(str)
      # str.unpack('U*').map { |c| "\\u#{c.to_s(16).upcase}" }.join
      str.codepoints.map { |c| "\\u#{c.to_s(16).upcase}" }.join
    end

    def ords
      str.chars.zip(str.codepoints.map(&:ord)).to_h
    end

    # charset
    def table(str)
      str.chars.zip(str.codepoints.map { |c| "\\u{#{c.to_s(16).upcase}}" }).to_h
    end
  end
end

KanaKana = Kanakana
