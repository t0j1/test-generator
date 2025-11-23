# frozen_string_literal: true

# ==================
# 定数定義
# ==================

# 科目データ（高校生向けに変更）
SUBJECTS_DATA = [
  { name: "英語", color_code: "#EF4444", sort_order: 1 },
  { name: "数学", color_code: "#3B82F6", sort_order: 2 },
  { name: "国語", color_code: "#10B981", sort_order: 3 },
  { name: "理科", color_code: "#8B5CF6", sort_order: 4 },
  { name: "社会", color_code: "#F59E0B", sort_order: 5 }
].freeze

# 単元データ（英語 - 高校生向け）
ENGLISH_UNITS_DATA = [
  { name: "高1 Lesson 1-5 基礎単語", grade: 1, sort_order: 1 },
  { name: "高1 Lesson 6-10 重要単語", grade: 1, sort_order: 2 },
  { name: "高2 Lesson 1-5 応用単語", grade: 2, sort_order: 1 },
  { name: "高2 Lesson 6-10 学術単語", grade: 2, sort_order: 2 },
  { name: "高3 大学受験 頻出単語", grade: 3, sort_order: 1 }
].freeze

# 易しい単語データ（高1基礎レベル）
WORDS_EASY = [
  { question: "achieve", answer: "達成する", hint: "動詞" },
  { question: "ancient", answer: "古代の", hint: "形容詞" },
  { question: "approach", answer: "近づく", hint: "動詞" },
  { question: "attitude", answer: "態度", hint: "名詞" },
  { question: "century", answer: "世紀", hint: "名詞" },
  { question: "climate", answer: "気候", hint: "名詞" },
  { question: "community", answer: "地域社会", hint: "名詞" },
  { question: "create", answer: "創造する", hint: "動詞" },
  { question: "culture", answer: "文化", hint: "名詞" },
  { question: "disease", answer: "病気", hint: "名詞" },
  { question: "encourage", answer: "励ます", hint: "動詞" },
  { question: "energy", answer: "エネルギー", hint: "名詞" },
  { question: "environment", answer: "環境", hint: "名詞" },
  { question: "establish", answer: "設立する", hint: "動詞" },
  { question: "evidence", answer: "証拠", hint: "名詞" },
  { question: "generation", answer: "世代", hint: "名詞" },
  { question: "global", answer: "世界的な", hint: "形容詞" },
  { question: "individual", answer: "個人", hint: "名詞" },
  { question: "industry", answer: "産業", hint: "名詞" },
  { question: "influence", answer: "影響", hint: "名詞" },
  { question: "organize", answer: "組織する", hint: "動詞" },
  { question: "political", answer: "政治的な", hint: "形容詞" },
  { question: "pollution", answer: "汚染", hint: "名詞" },
  { question: "resource", answer: "資源", hint: "名詞" },
  { question: "society", answer: "社会", hint: "名詞" }
].freeze

# 普通の単語データ（高1〜高2レベル）
WORDS_NORMAL = [
  { question: "accumulate", answer: "蓄積する", hint: "動詞" },
  { question: "adequate", answer: "適切な", hint: "形容詞" },
  { question: "agriculture", answer: "農業", hint: "名詞" },
  { question: "approximately", answer: "おおよそ", hint: "副詞" },
  { question: "colleague", answer: "同僚", hint: "名詞" },
  { question: "comprehend", answer: "理解する", hint: "動詞" },
  { question: "consequence", answer: "結果", hint: "名詞" },
  { question: "contemporary", answer: "現代の", hint: "形容詞" },
  { question: "demonstrate", answer: "実証する", hint: "動詞" },
  { question: "diversity", answer: "多様性", hint: "名詞" },
  { question: "elaborate", answer: "詳しく述べる", hint: "動詞" },
  { question: "emphasize", answer: "強調する", hint: "動詞" },
  { question: "fundamental", answer: "基本的な", hint: "形容詞" },
  { question: "implement", answer: "実行する", hint: "動詞" },
  { question: "inevitable", answer: "避けられない", hint: "形容詞" },
  { question: "innovative", answer: "革新的な", hint: "形容詞" },
  { question: "profound", answer: "深い", hint: "形容詞" },
  { question: "significant", answer: "重要な", hint: "形容詞" },
  { question: "sustainable", answer: "持続可能な", hint: "形容詞" },
  { question: "theoretical", answer: "理論的な", hint: "形容詞" }
].freeze

# 難しい単語データ（高2〜高3レベル）
WORDS_HARD = [
  { question: "ambiguous", answer: "曖昧な", hint: "形容詞" },
  { question: "comprehensive", answer: "包括的な", hint: "形容詞" },
  { question: "controversy", answer: "論争", hint: "名詞" },
  { question: "deteriorate", answer: "悪化する", hint: "動詞" },
  { question: "emergence", answer: "出現", hint: "名詞" },
  { question: "fluctuate", answer: "変動する", hint: "動詞" },
  { question: "hypothesis", answer: "仮説", hint: "名詞" },
  { question: "infrastructure", answer: "インフラ", hint: "名詞" },
  { question: "legitimate", answer: "正当な", hint: "形容詞" },
  { question: "mechanism", answer: "仕組み", hint: "名詞" },
  { question: "methodology", answer: "方法論", hint: "名詞" },
  { question: "paradigm", answer: "パラダイム", hint: "名詞" },
  { question: "predecessor", answer: "前任者", hint: "名詞" },
  { question: "stimulate", answer: "刺激する", hint: "動詞" },
  { question: "sophisticated", answer: "洗練された", hint: "形容詞" }
].freeze

# 大学受験頻出単語（高3レベル）
WORDS_ENTRANCE_EXAM = [
  { question: "acknowledge", answer: "認める", hint: "動詞", difficulty: :normal },
  { question: "advocate", answer: "主張する", hint: "動詞", difficulty: :normal },
  { question: "arbitrary", answer: "恣意的な", hint: "形容詞", difficulty: :hard },
  { question: "capitalism", answer: "資本主義", hint: "名詞", difficulty: :normal },
  { question: "circumstance", answer: "状況", hint: "名詞", difficulty: :normal },
  { question: "constitute", answer: "構成する", hint: "動詞", difficulty: :normal },
  { question: "constraint", answer: "制約", hint: "名詞", difficulty: :hard },
  { question: "contradiction", answer: "矛盾", hint: "名詞", difficulty: :hard },
  { question: "counterpart", answer: "対応するもの", hint: "名詞", difficulty: :hard },
  { question: "dilemma", answer: "ジレンマ", hint: "名詞", difficulty: :hard },
  { question: "dimension", answer: "次元", hint: "名詞", difficulty: :normal },
  { question: "discrimination", answer: "差別", hint: "名詞", difficulty: :normal },
  { question: "explicitly", answer: "明示的に", hint: "副詞", difficulty: :hard },
  { question: "feasible", answer: "実行可能な", hint: "形容詞", difficulty: :hard },
  { question: "hierarchy", answer: "階層", hint: "名詞", difficulty: :hard },
  { question: "inhibit", answer: "抑制する", hint: "動詞", difficulty: :hard },
  { question: "perspective", answer: "視点", hint: "名詞", difficulty: :normal },
  { question: "phenomenon", answer: "現象", hint: "名詞", difficulty: :normal },
  { question: "undergo", answer: "経験する", hint: "動詞", difficulty: :normal },
  { question: "virtue", answer: "美徳", hint: "名詞", difficulty: :hard }
].freeze

# ==================
# ヘルパー
# ==================

def clear_existing_data
  return unless Rails.env.development?

  Rails.logger.debug "🗑️  既存データを削除中..."

  # destroy_all → delete_all に変更（autoloadトラブル防止）
  TestQuestion.delete_all
  TestSheet.delete_all
  Question.delete_all
  Unit.delete_all
  Subject.delete_all

  Rails.logger.debug "✅ 既存データを削除しました"
end

def create_subjects
  Rails.logger.debug "\n📚 科目を作成中..."
  subjects = SUBJECTS_DATA.map { |data| Subject.create!(data) }
  Rails.logger.debug { "✅ 科目: #{Subject.count}件作成" }
  subjects
end

def create_units(english_subject)
  Rails.logger.debug "\n📖 単元を作成中..."
  units = ENGLISH_UNITS_DATA.map { |data| english_subject.units.create!(data) }
  Rails.logger.debug { "✅ 単元: #{Unit.count}件作成" }
  units
end

def create_questions(unit, words_data, difficulty, question_type = :word)
  words_data.each do |word|
    unit.questions.create!(
      question_type: question_type,
      question_text: word[:question],
      answer_text: word[:answer],
      hint: word[:hint],
      difficulty: word[:difficulty] || difficulty
    )
  end
end

def display_statistics
  Rails.logger.debug { "\n#{'=' * 60}" }
  Rails.logger.debug "🎉 Seed完了!"
  Rails.logger.debug "=" * 60
  Rails.logger.debug "📊 作成されたデータ:"
  Rails.logger.debug { "  科目: #{Subject.count}件" }
  Rails.logger.debug { "  単元: #{Unit.count}件" }
  Rails.logger.debug { "  問題: #{Question.count}件" }

  display_question_type_stats
  display_difficulty_stats
  display_unit_stats

  Rails.logger.debug "=" * 60
  Rails.logger.debug "✨ 高校生向けSeedデータの作成が完了しました！"
  Rails.logger.debug "=" * 60
end

def display_question_type_stats
  Rails.logger.debug "\n📈 問題タイプ別:"
  Question.question_types.each do |type, value|
    count = Question.public_send(type).count
    label = Question::QUESTION_TYPE_LABELS[type.to_s]
    Rails.logger.debug { "  - #{label} (#{type}, 値:#{value}): #{count}問" }
  end
end

def display_difficulty_stats
  Rails.logger.debug "\n📊 難易度別:"
  Question.difficulties.each do |diff, value|
    count = Question.public_send("difficulty_#{diff}").count
    label = Question::DIFFICULTY_LABELS[diff.to_s]
    Rails.logger.debug { "  - #{label} (#{diff}, 値:#{value}): #{count}問" }
  end
end

def display_unit_stats
  Rails.logger.debug "\n📚 単元別の問題数:"
  Unit.find_each do |unit|
    counts = unit.question_counts_by_difficulty
    Rails.logger.debug { "  #{unit.name}:" }
    Unit::DIFFICULTY_KEYS.each do |diff|
      label = Question::DIFFICULTY_LABELS[diff.to_s]
      Rails.logger.debug { "    - #{label}: #{counts[diff]}問" }
    end
    Rails.logger.debug { "    - 合計: #{counts[:total]}問" }
  end
end

# ==================
# メイン処理
# ==================

clear_existing_data

subjects = create_subjects
english = subjects.find { |s| s.name == "英語" }

units = create_units(english)
unit_h1_basic      = units[0]
unit_h1_important  = units[1]
unit_h2_advanced   = units[2]
unit_h3_exam       = units[4]

Rails.logger.debug "\n❓ 問題を作成中..."

create_questions(unit_h1_basic, WORDS_EASY, :easy)
Rails.logger.debug { "  ✓ 高1 基礎単語（易しい）: #{WORDS_EASY.size}問" }

create_questions(unit_h1_important, WORDS_NORMAL[0..9], :normal)
Rails.logger.debug "  ✓ 高1 重要単語（普通）: 10問"

create_questions(unit_h2_advanced, WORDS_NORMAL[10..14], :normal)
create_questions(unit_h2_advanced, WORDS_HARD[0..9], :hard)
Rails.logger.debug "  ✓ 高2 応用単語（普通5問 + 難しい10問）: 15問"

create_questions(unit_h3_exam, WORDS_ENTRANCE_EXAM, nil)
Rails.logger.debug { "  ✓ 高3 大学受験 頻出単語: #{WORDS_ENTRANCE_EXAM.size}問" }

Rails.logger.debug { "✅ 問題: #{Question.count}件作成" }

display_statistics
