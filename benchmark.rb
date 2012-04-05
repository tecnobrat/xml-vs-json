require 'nokogiri'
require 'json'
require 'benchmark'

small_xml_file = open("datafiles/small.xml").read.gsub(/\n/, "").squeeze(" ")
large_xml_file = open("datafiles/large.xml").read.gsub(/\n/, "").squeeze(" ")

small_json_file = open("datafiles/small.json").read.gsub(/\n/, "").squeeze(" ")
large_json_file = open("datafiles/large.json").read.gsub(/\n/, "").squeeze(" ")

def regex_xml(file)
  doc = /\<results\>(.*)\<\/results\>/.match(file)[1]
  doc = doc.split(/\<result\>(.*?)\<\/result\>/)
  doc.map do |result|
    next if result.strip == ""
    result = result.split(/\<.*?\>/)
    {
      :title => result[1],
      :description => result[3],
      :url => result[5]
    }
  end.compact
end

def xpath_xml(file)
  doc = Nokogiri::XML::Document.parse file

  doc.xpath('//results/result').map do |node|
    {
      :title => node.xpath('title').text,
      :description => node.xpath('description').text,
      :url => node.xpath('url').text
    }
  end
end

def parse_json(file)
  JSON.parse(file)
end

n = 100000

Benchmark.bmbm do |x|
  x.report("large json") { n.times { parse_json(large_json_file) } }
  x.report("small json") { n.times { parse_json(small_json_file) } }
  x.report("large xml xpath") { n.times { xpath_xml(large_xml_file) } }
  x.report("small xml xpath") { n.times { xpath_xml(small_xml_file) } }
  x.report("large xml regex") { n.times { regex_xml(large_xml_file) } }
  x.report("small xml regex") { n.times { regex_xml(small_xml_file) } }
end

puts
puts
puts "JSON Large File Size: #{large_json_file.size}"
puts "JSON Small File Size: #{small_json_file.size}"
puts "XML Large File Size: #{large_xml_file.size}"
puts "XML Small File Size: #{small_xml_file.size}"
