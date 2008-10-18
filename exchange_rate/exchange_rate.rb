#!/usr/bin/env ruby -wKU
=begin rdoc
==Synopsis
  Simple exchange rate calculator based on data from European Central Bank.

== Usage
  ruby exchange_rate.rb [N] [currency1] [currency2]

N:
  amount to convert.  If omitted, 1 is assumed.

currency1:
  currency to convert to.  If omitted, 'EUR' is assumed.

currency2:
  currency to convert from.  If omitted, 'USD' is assumed.


== Author
  Hirotsugu Asari
  
== Copyright
  Copyright 2008 Hirotsugu Asari

=end

require "rexml/document"
require "rexml/xpath"
require "open-uri"
# require "pp"


class Euro
  DATA_SOURCE_URL='http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml'
  
  attr_reader :data
  
  def initialize
    open DATA_SOURCE_URL do |f|
      @data = REXML::Document.new(f.read).elements[1]
      raise RuntimeError, "Failed to obtain exchange rates" if @data.nil?
    end
  end
  
  def in(currency)
    r=nil
    # add Euro
    euro = REXML::Element.new
    euro.add_attributes 'rate' => '1', 'currency' => 'EUR'

    REXML::XPath.each(@data, "//Cube[@time]/") do |e|
      e.add_element euro
      begin
        r = e.elements.select {|el| el.attributes['currency'] == currency.upcase}.first.attributes['rate']
      rescue Exception => e
        # raise e
      end
    end
    raise ArgumentError, "Unknown currency #{currency}" unless r
    return r.to_f
  end
  
  def method_missing(method_id)
    if method_id.id2name =~ %r[\Ain_([A-Z]{3})\z]i
      self.in($1)
    else
      super
    end
  end
  
end

class Currency
  def Currency.method_missing(method_id)
    @@euro ||= Euro.new
    
    if method_id.id2name =~ %r[\A([A-Z]{3})_(?:to|in)_([A-Z]{3})\z]i
      @@euro.in($2.upcase)/@@euro.in($1.upcase)
    else
      super
    end
  end
end


amount = (ARGV[0] =~ %r{\d+}) ? ARGV.shift : 1
currency1 = ARGV.shift || 'EUR'
currency2 = ARGV.shift || 'USD'

puts amount * Currency.send("#{currency1}_to_#{currency2}".to_sym)

__END__
<?xml version="1.0" encoding="UTF-8"?>
<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
	<gesmes:subject>Reference rates</gesmes:subject>
	<gesmes:Sender>
		<gesmes:name>European Central Bank</gesmes:name>
	</gesmes:Sender>
	<Cube>
		<Cube time='2008-09-29'>
			<Cube currency='AUD' rate='1.7615'/>  <!-- Australian Dollar -->
			<Cube currency='BGN' rate='1.9558'/>  <!-- Bulgarian Leva -->
			<Cube currency='BRL' rate='2.7115'/>  <!-- Brazilian Real-->
			<Cube currency='CAD' rate='1.4929'/>  <!-- Canadian Dollar -->
			<Cube currency='CHF' rate='1.5845'/>  <!-- Swiss Franc -->
			<Cube currency='CNY' rate='9.8269'/>  <!-- 中国人民元 -->
			<Cube currency='CZK' rate='24.605'/>  <!--　Czech Koruny  -->
			<Cube currency='DKK' rate='7.4603'/>  <!-- Danish Kroner -->
			<Cube currency='EEK' rate='15.6466'/> <!-- Estonian Kroon -->
			<Cube currency='GBP' rate='0.79590'/> <!-- British Pound -->
			<Cube currency='HKD' rate='11.1412'/> <!-- Hong Kong Dollar -->
			<Cube currency='HRK' rate='7.1075'/>  <!-- Croatia Kuna -->
			<Cube currency='HUF' rate='242.62'/>  <!-- Hungarian Forint -->
			<Cube currency='IDR' rate='13549.76'/><!-- Indian Rupee -->
			<Cube currency='ISK' rate='143.38'/>  <!-- Icelandic Kronur -->
			<Cube currency='JPY' rate='152.30'/>  <!-- 日本円　-->
			<Cube currency='KRW' rate='1700.21'/> <!-- 韓国ウォン  -->
			<Cube currency='LTL' rate='3.4528'/>  <!-- Lithuanian Litai-->
			<Cube currency='LVL' rate='0.7086'/>  <!-- Latvian Lati -->
			<Cube currency='MXN' rate='15.5603'/> <!-- Mexican Pesos -->
			<Cube currency='MYR' rate='4.9468'/>  <!-- Malaysian Ringgit -->
			<Cube currency='NOK' rate='8.3080'/>  <!-- Norwegian Krone -->
			<Cube currency='NZD' rate='2.1223'/>  <!-- New Zealand Dollar -->
			<Cube currency='PHP' rate='67.320'/>  <!-- Phillippine Peso -->
			<Cube currency='PLN' rate='3.3840'/>  <!-- Polish Zlotych -->
			<Cube currency='RON' rate='3.7010'/>  <!-- Romanian New Lei -->
			<Cube currency='RUB' rate='36.4460'/> <!-- Russian Ruble -->
			<Cube currency='SEK' rate='9.7009'/>  <!-- Swedish Kronor -->
			<Cube currency='SGD' rate='2.0558'/>  <!-- Singaporean Dollar -->
			<Cube currency='SKK' rate='30.305'/>  <!-- Slovak Koruna -->
			<Cube currency='THB' rate='48.866'/>  <!-- Thai Baht -->
			<Cube currency='TRY' rate='1.8056'/>  <!-- Turkish New Lira -->
			<Cube currency='USD' rate='1.4349'/>  <!-- US Dollar -->
			<Cube currency='ZAR' rate='11.7590'/> <!-- South African Rand -->
		</Cube>
	</Cube>
</gesmes:Envelope>