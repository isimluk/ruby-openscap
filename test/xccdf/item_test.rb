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
    benchmark do |b|
      item = b.items['xccdf_org.ssgproject.content_group_intro-root-shell-assumed']
      refute_nil item

      assert_equal item.description(markup: true), expected_markup
    end
  end

  def test_rationale_html
    expected_markup = "\n" \
                      "For AIDE to be effective, an initial database of <i xmlns=\"http://www.w3.org/1999/xhtml\">\"known-good\"</i> information about files\n" \
                      "must be captured and it should be able to be verified against the installed files.\n"
    benchmark do |b|
      item = b.items['xccdf_org.ssgproject.content_rule_aide_build_database']
      refute_nil item

      assert_equal item.rationale(markup: true), expected_markup
    end
  end

  def test_missing_rationale
    benchmark do |b|
      item_sans_rationale = b.items['xccdf_org.ssgproject.content_group_intro']
      refute_nil item_sans_rationale

      assert_equal item_sans_rationale.rationale(markup: true), nil
    end
  end

  def test_version
    benchmark do |b|
      item_sans_version = b.items['xccdf_org.ssgproject.content_group_intro']
      refute_nil item_sans_version
      assert_nil item_sans_version.version
    end
  end

  def test_references
    benchmark do |b|
      item = b.items['xccdf_org.ssgproject.content_rule_disable_prelink']
      refute_nil item
      item.references.tap do |refs|
        assert_equal refs.length, 4
        assert_equal refs.collect(&:title), ['CM-6(d)', 'CM-6(3)', 'SC-28', 'SI-7']
        assert_equal refs.collect(&:href).uniq, ['http://csrc.nist.gov/publications/nistpubs/800-53-Rev3/sp800-53-rev3-final.pdf']
      end
    end
  end

  def test_warnings
    expected_text = 'If verbose logging to <xhtml:code xmlns:xhtml="http://www.w3.org/1999/xhtml">vsftpd.log</xhtml:code> is done, sparse logging of downloads to <xhtml:code xmlns:xhtml="http://www.w3.org/1999/xhtml">/var/log/xferlog</xhtml:code> will not also occur. However, the information about what files were downloaded is included in the information logged to <xhtml:code xmlns:xhtml="http://www.w3.org/1999/xhtml">vsftpd.log</xhtml:code>'
    benchmark do |b|
      item = b.items['xccdf_org.ssgproject.content_rule_ftp_log_transactions']
      refute_nil item
      warns = item.warnings
      assert_equal warns.length, 1
      warning = warns[0]
      assert warning.instance_of?(Hash)
      assert warning.keys.length == 2
      assert warning[:category] == :general
      assert warning[:text].text == expected_text
    end
  end

  private

  def benchmark(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      OpenSCAP::Xccdf::Benchmark.new(source, &)
    end
  end
end
