# frozen_string_literal: true

require_relative '../settings'
class ServiceWorkingCsv
  def write_time(datetime, state)
    year = datetime.year.to_s
    month = SETTINGS::MONTHS[datetime.month]
    day = datetime.day.to_s


    Dir.chdir('storage')
    Dir.chdir(year)
    Dir.chdir(month)

    date_format = datetime.strftime('%H:%M:%S')

    File.open("#{day}.csv", 'a') do |file|
      file.puts "#{state} #{date_format}"
    end
  end
end
