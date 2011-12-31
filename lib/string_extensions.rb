# coding: utf-8
require 'unicode_utils/downcase'

class String
  # @see http://www.w3.org/TR/html4/sgml/entities.html
  def decode_html_entities
    gsub(/&#(\d+);/){|match|
      if 160 <= $1.to_i && $1.to_i <= 255
        $1.to_i.chr 'utf-8'
      else
        { '&#8194;' => ' ',
          '&#8195;' => ' ',
          '&#8201;' => ' ',
          '&#8204;' => '‌',
          '&#8205;' => '‍',
          '&#8206;' => '‎',
          '&#8207;' => '‏',
          '&#8211;' => '–',
          '&#8212;' => '—',
          '&#8216;' => '‘',
          '&#8217;' => '’',
          '&#8218;' => '‚',
          '&#8220;' => '“',
          '&#8221;' => '”',
          '&#8222;' => '„',
          '&#8224;' => '†',
          '&#8225;' => '‡',
          '&#8240;' => '‰',
          '&#8249;' => '‹',
          '&#8250;' => '›',
          '&#8364;' => '€',
        }[match]
      end
    }.gsub(/&([a-z]+);/){|match|
      { '&amp;' => '&',
        '&apos;' => "'",
        '&quot;' => '"',
      }[match]
    }
  end

  def slug
    UnicodeUtils.downcase(gsub(/[[:space:]—–-]+/, ' ').strip, :fr).gsub(/\p{Punct}|\p{Cntrl}/, '').split.join('-').tr(
      "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
      "aaaaaaaaaaaaaaaaaaccccccccccddddddeeeeeeeeeeeeeeeeeegggggggghhhhiiiiiiiiiiiiiiiiiijjkkkllllllllllnnnnnnnnnnnoooooooooooooooooorrrrrrsssssssssttttttuuuuuuuuuuuuuuuuuuuuwwyyyyyyzzzzzz")
  end
end
