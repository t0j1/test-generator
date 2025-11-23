require "application_system_test_case"

class TestSheetCreationTest < ApplicationSystemTestCase
  # テストデータのセットアップ
  setup do
    # 科目作成
    @subject_english = Subject.create!(
      name: "英語",
      display_order: 1
    )
    
    @subject_math = Subject.create!(
      name: "数学",
      display_order: 2
    )
    
    # 単元作成（英語）
    @unit_english_1 = Unit.create!(
      subject: @subject_english,
      name: "現在完了形",
      grade: 1,
      display_order: 1
    )
    
    @unit_english_2 = Unit.create!(
      subject: @subject_english,
      name: "不定詞",
      grade: 2,
      display_order: 2
    )
    
    # 単元作成（数学）
    @unit_math_1 = Unit.create!(
      subject: @subject_math,
      name: "二次関数",
      grade: 1,
      display_order: 1
    )
    
    # 問題作成（英語 - 現在完了形）
    10.times do |i|
      Question.create!(
        unit: @unit_english_1,
        difficulty: %w[easy normal hard].sample,
        word: "test_word_#{i}",
        meaning: "テスト単語#{i}",
        hint: "ヒント#{i}"
      )
    end
    
    # 問題作成（英語 - 不定詞）
    5.times do |i|
      Question.create!(
        unit: @unit_english_2,
        difficulty: "easy",
        word: "infinitive_#{i}",
        meaning: "不定詞#{i}",
        hint: "ヒント#{i}"
      )
    end
    
    # 問題作成（数学 - 二次関数）
    8.times do |i|
      Question.create!(
        unit: @unit_math_1,
        difficulty: %w[easy normal].sample,
        word: "math_term_#{i}",
        meaning: "数学用語#{i}",
        hint: "数学ヒント#{i}"
      )
    end
  end

  test "科目クリック後に単元選択が表示される" do
    visit root_path
    
    # 初期状態：単元選択は非表示
    assert_selector "[data-test-form-target='unitSection'].hidden"
    
    # 科目「英語」をクリック
    find("input[name='test_sheet[subject_id]'][value='#{@subject_english.id}']", visible: false).execute_script("this.click()")
    
    # 単元選択セクションが表示される（hiddenクラスが外れる）
    assert_no_selector "[data-test-form-target='unitSection'].hidden", wait: 5
    assert_selector "[data-test-form-target='unitSection']", visible: true
    
    # 単元リストが表示される
    assert_text "2. 単元を選んでください"
    assert_text "現在完了形"
    assert_text "不定詞"
    
    # コンソールログを確認（手動確認用）
    puts "✅ 科目選択後に単元セクションが正しく表示されました"
  end

  test "単元選択後に設定セクションが表示される" do
    visit root_path
    
    # 科目「英語」を選択
    find("input[name='test_sheet[subject_id]'][value='#{@subject_english.id}']", visible: false).execute_script("this.click()")
    
    # 単元が読み込まれるまで待機
    assert_text "現在完了形", wait: 5
    
    # 初期状態：設定セクションは非表示
    assert_selector "[data-test-form-target='settingsSection'].hidden"
    
    # 単元「現在完了形」を選択
    find("input[name='test_sheet[unit_id]'][value='#{@unit_english_1.id}']", visible: false).execute_script("this.click()")
    
    # 設定セクションが表示される
    assert_no_selector "[data-test-form-target='settingsSection'].hidden", wait: 5
    assert_selector "[data-test-form-target='settingsSection']", visible: true
    
    # 設定項目が表示される
    assert_text "3. テストの設定"
    assert_text "難易度"
    assert_text "問題数"
    
    # 送信ボタンセクションも表示される
    assert_no_selector "[data-test-form-target='submitSection'].hidden"
    assert_selector "[data-test-form-target='submitSection']", visible: true
    
    puts "✅ 単元選択後に設定セクションが正しく表示されました"
  end

  test "科目変更時に単元リストが更新される" do
    visit root_path
    
    # 科目「英語」を選択
    find("input[name='test_sheet[subject_id]'][value='#{@subject_english.id}']", visible: false).execute_script("this.click()")
    
    # 英語の単元が表示される
    assert_text "現在完了形", wait: 5
    assert_text "不定詞"
    
    # 科目「数学」に変更
    find("input[name='test_sheet[subject_id]'][value='#{@subject_math.id}']", visible: false).execute_script("this.click()")
    
    # 数学の単元が表示される
    assert_text "二次関数", wait: 5
    
    # 英語の単元は表示されない
    assert_no_text "現在完了形"
    assert_no_text "不定詞"
    
    puts "✅ 科目変更時に単元リストが正しく更新されました"
  end

  test "利用可能な問題数がリアルタイムで更新される" do
    visit root_path
    
    # 科目「英語」を選択
    find("input[name='test_sheet[subject_id]'][value='#{@subject_english.id}']", visible: false).execute_script("this.click()")
    
    # 単元「現在完了形」を選択（10問登録済み）
    assert_text "現在完了形", wait: 5
    find("input[name='test_sheet[unit_id]'][value='#{@unit_english_1.id}']", visible: false).execute_script("this.click()")
    
    # 利用可能問題数が表示される
    assert_text "利用可能な問題数:", wait: 5
    
    # 問題数が10問であることを確認
    within "[data-test-form-target='availableInfo']" do
      assert_text "10"
    end
    
    puts "✅ 利用可能問題数が正しく表示されました"
  end

  test "完全なテスト作成フローが動作する" do
    visit root_path
    
    # Step 1: 科目選択
    find("input[name='test_sheet[subject_id]'][value='#{@subject_english.id}']", visible: false).execute_script("this.click()")
    assert_text "現在完了形", wait: 5
    
    # Step 2: 単元選択
    find("input[name='test_sheet[unit_id]'][value='#{@unit_english_1.id}']", visible: false).execute_script("this.click()")
    assert_text "3. テストの設定", wait: 5
    
    # Step 3: 設定
    select "全難易度ミックス", from: "test_sheet[difficulty]"
    select "5", from: "test_sheet[question_count]"
    
    # Step 4: テスト作成
    click_button "テストを作成"
    
    # テスト表示画面に遷移
    assert_text "単語テスト", wait: 10
    assert_text "英語"
    assert_text "現在完了形"
    
    puts "✅ 完全なテスト作成フローが正しく動作しました"
  end

  test "Stimulusコントローラーが正しく接続される" do
    visit root_path
    
    # ページが読み込まれるまで待機
    sleep 1
    
    # Stimulusコントローラーのターゲットが存在することを確認
    assert_selector "[data-controller='test-form']"
    assert_selector "[data-test-form-target='subjectRadio']"
    assert_selector "[data-test-form-target='unitSection']"
    assert_selector "[data-test-form-target='settingsSection']"
    assert_selector "[data-test-form-target='submitSection']"
    
    # ブラウザコンソールログで接続を確認（手動確認用）
    # コンソールに "✅ TestFormController connected" が出力されているはず
    
    puts "✅ Stimulusコントローラーのターゲットが正しく設定されています"
  end
end
