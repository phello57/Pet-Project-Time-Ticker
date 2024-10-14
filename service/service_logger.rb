# frozen_string_literal: true

class ServiceLogger
  attr_writer :mode, :time_start

  def initialize
    @mode = ''
    @time_start = nil
  end

  def print_current_diapazon(start_time, end_time, secs)
    puts "    За диапазон #{start_time.slice(-8, 8)} по #{end_time.slice(-8, 8)} было отработано #{secs} секунд"
  end

  def print_total(total, seconds)
    total_time = total + (seconds.nil? ? 0 : seconds)

    month = SETTINGS::MONTHS_SKLONENIE[@time_start.month]
    hours = (total_time / 60 / 60).floor
    mins = ((total_time - hours) / 60).floor
    secs = total_time - (hours * 3600) - (mins * 60)

    if @mode == 'start'
      puts "Прошло с начала работы программы #{format('%02d',
                                                      hours)}:#{format('%02d', mins)}:#{format('%02d', secs)}"
    elsif @mode == 'total'
      puts "Всего программа за #{@time_start.day} #{month} отработала #{format('%02d',
                                                                               hours)}:#{format('%02d',
                                                                                                mins)}:#{format('%02d',
                                                                                                                secs)}"
    end
  end
end
