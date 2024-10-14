# frozen_string_literal: true

require_relative '../settings'
class ServiceCreateFolders
  def create_year_month_folder(date)
    year = date.year.to_s
    month = SETTINGS::MONTHS[date.month]

    Dir.exist?('storage') ? nil : Dir.mkdir('storage')
    Dir.chdir('storage')
    Dir.exist?(year) ? nil : Dir.mkdir(year)
    Dir.chdir(year)
    Dir.exist?(month) ? nil : Dir.mkdir(month)
  end
end
