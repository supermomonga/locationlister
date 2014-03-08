# encoding: utf-8

require 'bundler'
Bundler.require
require 'csv'

def csv_path sheet_name
  doc_name = 'ebay送料-システム用'
  "./data/#{doc_name} - #{sheet_name}.csv"
end

zones             = CSV.table csv_path('ゾーン一覧')         , header_converters: nil
countries         = CSV.table csv_path('国一覧')             , header_converters: nil
methods           = CSV.table csv_path('発送方法一覧')       , header_converters: nil
countries_methods = CSV.table csv_path('国×発送方法')       , header_converters: nil
methods_weights   = CSV.table csv_path('発送方法×重量一覧') , header_converters: nil

cs = countries.map{|r|
  country = r['国名']
  {
    name: country.gsub("\n", ' '),
    methods: countries_methods.select{|r| r['国名'] == country && r['発送可否'] == 'OK'}.map{|r|r['発送方法一覧.発送方法名']}.sort,
    zone_orig: r['ゾーン一覧.ゾーン名']
  }
}

new_zones = cs.group_by{|c|
  [c[:methods], c[:zone_orig]].join
}

# cs.map{|c|
#   ms = c[:methods]
#   if ms.size != ms.uniq.size
#     puts c[:name]
#     puts c[:methods].join("\n")
#     puts
#   end
# }
# exit

new_zones.each.with_index(1) do |(k,cs),i|
  nhead, *ntail = cs.map{|r|r[:name]}
  mhead, *mtail = cs.first[:methods]
  puts "ZONE#{i}:"
  puts "  countries: - #{nhead}"
  ntail.each do |n|
    puts "             - #{n}"
  end
  if mhead
    puts "  methods  : - #{mhead}"
    mtail.each do |m|
      puts "             - #{m}"
    end
  else
    puts "  methods  : (NONE)"
  end
  puts
end
