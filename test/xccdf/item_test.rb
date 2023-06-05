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

  def benchmark(&)
    OpenSCAP::Source.new '../data/xccdf.xml' do |source|
      OpenSCAP::Xccdf::Benchmark.new(source, &)
    end
  end
end
