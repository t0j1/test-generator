/**
 * Stimulus TestFormController のユニットテスト
 * 
 * このテストは、Node.js環境で実行するためのテストです。
 * 実行方法: node test/javascript/test_form_controller.test.js
 */

// テストヘルパー
class TestHelper {
  constructor() {
    this.tests = [];
    this.passed = 0;
    this.failed = 0;
  }

  describe(description, fn) {
    console.log(`\n📋 ${description}`);
    fn();
  }

  test(name, fn) {
    try {
      fn();
      this.passed++;
      console.log(`  ✅ ${name}`);
    } catch (error) {
      this.failed++;
      console.log(`  ❌ ${name}`);
      console.log(`     Error: ${error.message}`);
    }
  }

  assert(condition, message) {
    if (!condition) {
      throw new Error(message || "Assertion failed");
    }
  }

  assertEqual(actual, expected, message) {
    if (actual !== expected) {
      throw new Error(message || `Expected ${expected} but got ${actual}`);
    }
  }

  assertIncludes(array, value, message) {
    if (!array.includes(value)) {
      throw new Error(message || `Expected array to include ${value}`);
    }
  }

  summary() {
    const total = this.passed + this.failed;
    console.log(`\n${'='.repeat(50)}`);
    console.log(`📊 Test Summary:`);
    console.log(`   Total: ${total}`);
    console.log(`   ✅ Passed: ${this.passed}`);
    console.log(`   ❌ Failed: ${this.failed}`);
    console.log(`${'='.repeat(50)}\n`);
    
    if (this.failed === 0) {
      console.log("🎉 All tests passed!");
      return 0;
    } else {
      console.log("💔 Some tests failed.");
      return 1;
    }
  }
}

const test = new TestHelper();

// モックDOM要素
class MockElement {
  constructor(tagName = 'div') {
    this.tagName = tagName;
    this.classList = new MockClassList();
    this.innerHTML = '';
    this.textContent = '';
    this.value = '';
    this.dataset = {};
    this.disabled = false;
  }
}

class MockClassList {
  constructor() {
    this.classes = [];
  }

  add(className) {
    if (!this.classes.includes(className)) {
      this.classes.push(className);
    }
  }

  remove(className) {
    const index = this.classes.indexOf(className);
    if (index > -1) {
      this.classes.splice(index, 1);
    }
  }

  contains(className) {
    return this.classes.includes(className);
  }

  toggle(className) {
    if (this.contains(className)) {
      this.remove(className);
    } else {
      this.add(className);
    }
  }
}

// TestFormController のモック
class TestFormController {
  constructor() {
    this.unitSectionTarget = new MockElement();
    this.settingsSectionTarget = new MockElement();
    this.submitSectionTarget = new MockElement();
    this.unitListTarget = new MockElement();
    
    // 初期状態: hidden クラスを付与
    this.unitSectionTarget.classList.add('hidden');
    this.settingsSectionTarget.classList.add('hidden');
    this.submitSectionTarget.classList.add('hidden');
    
    this.units = {};
    this.selectedUnitId = null;
  }

  hasUnitSectionTarget() {
    return !!this.unitSectionTarget;
  }

  hasSettingsSectionTarget() {
    return !!this.settingsSectionTarget;
  }

  hasSubmitSectionTarget() {
    return !!this.submitSectionTarget;
  }

  hasUnitListTarget() {
    return !!this.unitListTarget;
  }

  // 科目選択時の処理
  onSubjectChange(event) {
    const subjectId = event.target.value;
    
    // Step 2（単元選択）を表示
    if (this.hasUnitSectionTarget()) {
      this.unitSectionTarget.classList.remove("hidden");
    }
    
    // Step 3, 4 を非表示
    if (this.hasSettingsSectionTarget()) {
      this.settingsSectionTarget.classList.add("hidden");
    }
    if (this.hasSubmitSectionTarget()) {
      this.submitSectionTarget.classList.add("hidden");
    }
  }

  // 単元選択時の処理
  onUnitChange(event) {
    this.selectedUnitId = event.target.value;

    if (this.hasSettingsSectionTarget()) {
      this.settingsSectionTarget.classList.remove("hidden");
    }
    if (this.hasSubmitSectionTarget()) {
      this.submitSectionTarget.classList.remove("hidden");
    }
  }
}

// テストケース
test.describe("TestFormController", () => {
  test.test("初期状態では全セクションがhiddenクラスを持つ", () => {
    const controller = new TestFormController();
    
    test.assert(
      controller.unitSectionTarget.classList.contains('hidden'),
      "unitSection should have hidden class"
    );
    test.assert(
      controller.settingsSectionTarget.classList.contains('hidden'),
      "settingsSection should have hidden class"
    );
    test.assert(
      controller.submitSectionTarget.classList.contains('hidden'),
      "submitSection should have hidden class"
    );
  });

  test.test("科目選択時に単元セクションのhiddenクラスが削除される", () => {
    const controller = new TestFormController();
    const mockEvent = {
      target: { value: "1" }
    };
    
    controller.onSubjectChange(mockEvent);
    
    test.assert(
      !controller.unitSectionTarget.classList.contains('hidden'),
      "unitSection hidden class should be removed"
    );
  });

  test.test("科目選択時に設定・送信セクションがhiddenになる", () => {
    const controller = new TestFormController();
    
    // まず単元・設定・送信を全て表示状態にする
    controller.unitSectionTarget.classList.remove('hidden');
    controller.settingsSectionTarget.classList.remove('hidden');
    controller.submitSectionTarget.classList.remove('hidden');
    
    // 科目を変更
    const mockEvent = { target: { value: "2" } };
    controller.onSubjectChange(mockEvent);
    
    // 単元は表示、設定・送信は非表示
    test.assert(
      !controller.unitSectionTarget.classList.contains('hidden'),
      "unitSection should be visible"
    );
    test.assert(
      controller.settingsSectionTarget.classList.contains('hidden'),
      "settingsSection should be hidden"
    );
    test.assert(
      controller.submitSectionTarget.classList.contains('hidden'),
      "submitSection should be hidden"
    );
  });

  test.test("単元選択時に設定・送信セクションのhiddenクラスが削除される", () => {
    const controller = new TestFormController();
    const mockEvent = {
      target: { 
        value: "10",
        dataset: { unitName: "現在完了形" }
      }
    };
    
    controller.onUnitChange(mockEvent);
    
    test.assert(
      !controller.settingsSectionTarget.classList.contains('hidden'),
      "settingsSection hidden class should be removed"
    );
    test.assert(
      !controller.submitSectionTarget.classList.contains('hidden'),
      "submitSection hidden class should be removed"
    );
    test.assertEqual(
      controller.selectedUnitId,
      "10",
      "selectedUnitId should be set"
    );
  });

  test.test("hasターゲットメソッドが正常に動作する", () => {
    const controller = new TestFormController();
    
    test.assert(controller.hasUnitSectionTarget(), "hasUnitSectionTarget should return true");
    test.assert(controller.hasSettingsSectionTarget(), "hasSettingsSectionTarget should return true");
    test.assert(controller.hasSubmitSectionTarget(), "hasSubmitSectionTarget should return true");
    test.assert(controller.hasUnitListTarget(), "hasUnitListTarget should return true");
  });
});

test.describe("ClassList動作確認", () => {
  test.test("classList.add() が正常に動作する", () => {
    const element = new MockElement();
    element.classList.add('hidden');
    
    test.assert(element.classList.contains('hidden'), "Should contain 'hidden' class");
  });

  test.test("classList.remove() が正常に動作する", () => {
    const element = new MockElement();
    element.classList.add('hidden');
    element.classList.remove('hidden');
    
    test.assert(!element.classList.contains('hidden'), "Should not contain 'hidden' class");
  });

  test.test("classList.toggle() が正常に動作する", () => {
    const element = new MockElement();
    element.classList.toggle('hidden');
    
    test.assert(element.classList.contains('hidden'), "Should contain 'hidden' class after first toggle");
    
    element.classList.toggle('hidden');
    test.assert(!element.classList.contains('hidden'), "Should not contain 'hidden' class after second toggle");
  });

  test.test("重複するクラス追加を防ぐ", () => {
    const element = new MockElement();
    element.classList.add('hidden');
    element.classList.add('hidden');
    element.classList.add('hidden');
    
    test.assertEqual(element.classList.classes.length, 1, "Should only have one 'hidden' class");
  });
});

test.describe("修正の検証", () => {
  test.test("インラインスタイルの問題を再現", () => {
    // インラインスタイル style="display: none;" の問題
    const elementWithInlineStyle = {
      style: { display: 'none' },
      classList: new MockClassList()
    };
    
    elementWithInlineStyle.classList.add('hidden');
    elementWithInlineStyle.classList.remove('hidden');
    
    // classList操作は成功するが、インラインスタイルは残る
    test.assert(
      !elementWithInlineStyle.classList.contains('hidden'),
      "hidden class should be removed"
    );
    test.assertEqual(
      elementWithInlineStyle.style.display,
      'none',
      "Inline style should still be 'none' (this is the bug)"
    );
  });

  test.test("Tailwind hiddenクラスの動作", () => {
    // Tailwind hidden クラスのみを使用
    const elementWithClass = new MockElement();
    elementWithClass.classList.add('hidden');
    
    test.assert(
      elementWithClass.classList.contains('hidden'),
      "Should have hidden class"
    );
    
    // classList.remove() で削除
    elementWithClass.classList.remove('hidden');
    
    test.assert(
      !elementWithClass.classList.contains('hidden'),
      "hidden class should be removed successfully"
    );
  });
});

// テスト実行
const exitCode = test.summary();
process.exit(exitCode);
