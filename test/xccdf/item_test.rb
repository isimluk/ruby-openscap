# frozen_string_literal: true

require 'openscap'
require 'openscap/xccdf/benchmark'
require 'common/testcase'

class ItemTest < OpenSCAP::TestCase
  def test_description_html
    expected_markup = "\n" \
                      "Most of the actions listed in this document are written with the\n" \
                      "assumption that they will be executed by the root user running the\n" \
                      "<xhtml:code xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">/bin/bash</xhtml:code> shell. Commands preceded with a hash mark (#)\n" \
                      "assume that the administrator will execute the commands as root, i.e.\n" \
                      "apply the command via <xhtml:code xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">sudo</xhtml:code> whenever possible, or use\n" \
                      "<xhtml:code xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">su</xhtml:code> to gain root privileges if <xhtml:code xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">sudo</xhtml:code> cannot be\n" \
                      "used. Commands which can be executed as a non-root user are are preceded\n" \
                      "by a dollar sign ($) prompt.\n"
    with_item 'xccdf_org.ssgproject.content_group_intro-root-shell-assumed' do |item|
      assert_equal item.description(markup: true), expected_markup
    end
  end

  def test_rationale_html
    expected_markup = "\n" \
                      "For AIDE to be effective, an initial database of <i xmlns=\"http://www.w3.org/1999/xhtml\">\"known-good\"</i> information about files\n" \
                      "must be captured and it should be able to be verified against the installed files.\n"
    with_item 'xccdf_org.ssgproject.content_rule_aide_build_database' do |item|
      assert_equal item.rationale(markup: true), expected_markup
    end
  end

  def test_missing_rationale
    with_item 'xccdf_org.ssgproject.content_group_intro' do |item_sans_rationale|
      assert_equal item_sans_rationale.rationale(markup: true), nil
    end
  end

  def test_version
    with_item 'xccdf_org.ssgproject.content_group_intro' do |item_sans_version|
      assert_nil item_sans_version.version
    end
  end

  def test_references
    with_item 'xccdf_org.ssgproject.content_rule_disable_prelink' do |item|
      item.references.tap do |refs|
        assert_equal refs.length, 4
        assert_equal refs.collect(&:title), ['CM-6(d)', 'CM-6(3)', 'SC-28', 'SI-7']
        assert_equal refs.collect(&:href).uniq, ['http://csrc.nist.gov/publications/nistpubs/800-53-Rev3/sp800-53-rev3-final.pdf']
      end
    end
  end

  def test_warnings
    expected_text = 'If verbose logging to <xhtml:code xmlns:xhtml="http://www.w3.org/1999/xhtml">vsftpd.log</xhtml:code> is done, sparse logging of downloads to <xhtml:code xmlns:xhtml="http://www.w3.org/1999/xhtml">/var/log/xferlog</xhtml:code> will not also occur. However, the information about what files were downloaded is included in the information logged to <xhtml:code xmlns:xhtml="http://www.w3.org/1999/xhtml">vsftpd.log</xhtml:code>'
    with_item 'xccdf_org.ssgproject.content_rule_ftp_log_transactions' do |item|
      warns = item.warnings
      assert_equal warns.length, 1
      warning = warns[0]
      assert warning.instance_of?(Hash)
      assert warning.keys.length == 2
      assert warning[:category] == :general
      assert warning[:text].text == expected_text
    end
  end

  def test_fixtexts
    with_item 'xccdf_org.ssgproject.content_rule_ftp_log_transactions' do |item|
      assert_equal item.fixtexts.length, 1
      fix = item.fixtexts.first
      assert_equal fix.text, 'fix it like a boss'
      assert_equal false, fix.reboot
      assert_equal :strategy_unknown, fix.strategy
      assert_equal :level_not_defined, fix.disruption
    end
  end

  def test_items_fixes
    expected_content = "var_accounts_minimum_age_login_defs=\"<sub xmlns=\"http://checklists.nist.gov/xccdf/1.2\" idref=\"xccdf_org.ssgproject.content_value_var_accounts_minimum_age_login_defs\" use=\"legacy\"/>\"\ngrep -q ^PASS_MIN_DAYS /etc/login.defs &amp;&amp; \\\nsed -i \"s/PASS_MIN_DAYS.*/PASS_MIN_DAYS\\t$var_accounts_minimum_age_login_defs/g\" /etc/login.defs\nif ! [ $? -eq 0 ]\nthen\n  echo -e \"PASS_MIN_DAYS\\t$var_accounts_minimum_age_login_defs\" &gt;&gt; /etc/login.defs\nfi\n"
    expected_hashes = {
      id: nil,
      platform: nil,
      content: expected_content,
      system: 'urn:xccdf:fix:script:sh'
    }

    with_item 'xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs' do |login_defs_rule|
      assert_equal login_defs_rule.fixes.length, 1

      fix = login_defs_rule.fixes.first
      assert_equal expected_content, fix.content
      assert_equal expected_hashes, fix.to_hash
      assert_equal false, fix.reboot
      assert_equal :strategy_unknown, fix.strategy
      assert_equal :level_not_defined, fix.disruption
    end
  end

  private

  def with_item(id, &)
    with_benchmark do |b|
      item = b.items[id]
      refute_nil item
      yield item
    end
  end

  def with_benchmark(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      OpenSCAP::Xccdf::Benchmark.new(source, &)
    end
  end
end
