RSpec.describe Kanakana do
  it 'has a version number' do
    expect(Kanakana::VERSION).not_to be nil
  end

  it 'test nigorize' do
    src = []
    dst = []
    src << 'にほんごカタカナ生きたい'
    dst << 'にぼんごガダガナ生ぎだい'

    # 結合文字はは正規化する。
    src << 'が' # "\u304B\u3099" # 結合文字
    dst << 'が' # "\u304C"

    src << "\u304B\u3099"
    dst << "\u304C"
    src.zip(dst) do |src, dst|
      expect(Kanakana.nigorize(src)).to eq(dst)
    end
  end

  it 'test hyper_nigorize' do
    src = []
    dst = []
    src << 'にほんごカタカナ生きたい'
    dst << 'に゙ぼん゙ごガダガナ゙生ぎだい゙'

    # 結合文字はは正規化する。
    src << 'が' # "\u304B\u3099" # 結合文字
    dst << 'が' # "\u304C"

    src << "\u304B\u3099"
    dst << "\u304C"
    src.zip(dst) do |src, dst|
      expect(Kanakana.hyper_nigorize(src)).to eq(dst)
    end
  end

  it 'test katakanize' do
    src = ['']
    dst = src.map(&:dup)

    src << 'ゐゑにほんごニホンゴﾆﾎﾝｺﾞ'
    dst << 'ヰヱニホンゴニホンゴニホンゴ'
    src.zip(dst) do |src, dst|
      expect(Kanakana.katakanize(src)).to eq(dst)
    end
  end

  it 'test hiraganize' do
    src = ['']
    dst = src.map(&:dup)

    src << 'ｺﾅｺﾞﾅ、ﾊﾝｶｸ, ゼンカク。半角スペース→ |　←全角スペース。ひらがなヰヱゟ'
    dst << 'こなごな、はんかく, ぜんかく。半角すぺーす→ |　←全角すぺーす。ひらがなゐゑゟ'

    src << "\uFF9E\uFF9F" # 半角カナの濁点,半濁点
    dst << "\u309B\u309C" # 全角仮名の濁点、半濁点 (not 結合文字)
    src.zip(dst) do |src, dst|
      expect(Kanakana.hiraganize(src)).to eq(dst)
    end
  end

  # [Rubyで文字化けせずに全角英数字を半角英数字に変換する方法 \- Qiita](https://qiita.com/y-ken/items/17181f322d0413edd3dc)
  it 'test make_ascii' do
    src = ['ルⅡ', 'Ruby Ⅱ', "\u30FC"]
    dst = src.map(&:dup)
    # "\u30FC"は、長音(全角の長音、カタカナの後ろにあるのでカタカナと同類だろう)

    src << 'Ｒｕｂｙ-２．２'
    dst << 'Ruby-2.2'

    src << "\uFF0D" # 全角ハイフン(マイナスの意味ももつ) # 全角アスキーの並びにある
    dst << '-'

    # src << '‐' # "\u2010" # ハイフン。MacでGoogle日本語入力だと「全角ハイフン」というが、全角に見えない。
    # dst << '-' # "\u002D" # アスキーの半角ハイフン=マイナス

    src << '−' # "\u2212" # 全角のマイナス
    dst << '-' # "\u002D" # 半角ハイフン(マイナスの意味も持つ)

    src << 'ｒｕｂｙ−ｌａｎｇ＠ｅｘａｍｐｌｅ．ｃｏｍ'
    dst << 'ruby-lang@example.com'

    src << '全角カンマ，は半角カンマに'
    dst << '全角カンマ,は半角カンマに'

    src << '！？'
    dst << '!?'

    src.zip(dst) do |src, dst|
      # p Kanakana.unicodes(src)
      # p Kanakana.unicodes(dst)
      expect(Kanakana.make_ascii(src)).to eq(dst)
    end
  end

  it 'test unicodes' do
    expect(Kanakana.unicodes('𩸽')).to eq(['U+29E3D'])

    src = ['']
    dst = [[]]

    src << '👨‍👩‍👧‍👦'
    dst << ['U+1F468', 'U+200D', 'U+1F469', 'U+200D', 'U+1F467', 'U+200D', 'U+1F466']
    src.zip(dst) do |src, dst|
      expect(Kanakana.unicodes(src)).to eq(dst)
    end
  end

  it 'escape' do
    expect(Kanakana.escape('𩸽')).to eq('\u29E3D')

    src = ['']
    dst = src.map(&:dup)

    src << '👨‍👩‍👧‍👦'
    dst << '\u1F468\u200D\u1F469\u200D\u1F467\u200D\u1F466'
    src.zip(dst) do |src, dst|
      expect(Kanakana.escape(src)).to eq(dst)
    end
  end

  it 'table' do
    src = ['']
    dst = [{}]

    src << 'たちまち'
    dst << { 'た' => '\u{305F}', 'ち' => '\u{3061}', 'ま' => '\u{307E}' }

    src << '👨‍👩‍👧‍👦'
    dst << { '👨' => '\u{1F468}', '‍' => '\u{200D}', '👩' => '\u{1F469}', '👧' => '\u{1F467}', '👦' => '\u{1F466}' }
    src.zip(dst) do |src, dst|
      expect(Kanakana.table(src)).to eq(dst)
    end
  end
end
