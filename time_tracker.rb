# frozen_string_literal: true

class TimeTracker
  def initialize(mode, time_start, serv_create_folder, serv_csv, serv_logger)
    @mode = mode
    @time_start = time_start
    @serv_folder = serv_create_folder
    @serv_csv = serv_csv
    @one_day = 86_400 # sec
    @total_time = 0
    @serv_logger = serv_logger

    @serv_logger.time_start = time_start
    @serv_logger.mode = mode
  end

  def run
    case @mode
    when 'start' then start
    when 'total' then total
    end
  end

  def start
    @is_logger_turn = false


    write_to_file(@time_start, SETTINGS::STATE_START)

    calc_total
    secs = 0

    last_time = Time.now

    loop do
      if Time.now - last_time >= 1
        secs += 1
        @serv_logger.print_total(@total_time, secs)
        last_time = Time.now
      end

      Signal.trap('INT') do
        time_end = Time.now

        if @time_start.day == time_end.day
          write_to_file(time_end, SETTINGS::STATE_END)
        else
          write_some_days(@time_start, time_end)
        end

        exit
      end
    end
  end

  def write_to_file(date, state)
    refresh_root

    @serv_folder.create_year_month_folder(date)

    refresh_root

    @serv_csv.write_time(date, state)

    refresh_root
  end

  def write_some_days(time_start, time_end)
    count_days = ((time_end - time_start) / @one_day).floor

    count_days.times do |i|
      day = i * @one_day


      cur_day = time_start + day
      time_end_prev_day = Time.new(cur_day.year \
                                   , cur_day.month \
                                   , cur_day.day \
                                   , 23, 59, 59)

      next_day = time_start + day + @one_day
      time_start_prev_day = Time.new(next_day.year \
                                     , next_day.month \
                                     , next_day.day \
                                     , 0o0, 0o0, 0o0)


      write_to_file(time_end_prev_day, SETTINGS::STATE_END)
      write_to_file(time_start_prev_day, SETTINGS::STATE_START)
    end

    write_to_file(time_end, SETTINGS::STATE_END)
  end

  def total
    month = SETTINGS::MONTHS_SKLONENIE[@time_start.month]
    calc_total
    @serv_logger.print_total(@total_time, nil)
  rescue Errno::ENOENT
    puts "Программа за #{@time_start.day} #{month} не работала"
  end

  def calc_total
    require 'csv'

    year = @time_start.year.to_s
    month = SETTINGS::MONTHS[@time_start.month]
    day = @time_start.day.to_s

    Dir.chdir('storage')
    Dir.chdir(year)
    Dir.chdir(month)

    File.open("#{day}.csv", 'a') do |file|
      work_time = CSV.parse(File.read(file))

      (0..work_time.size).step(2) do |i|
        if !work_time[i].nil? && !work_time[i + 1].nil?
          start_time = work_time[i][0]

          end_time = work_time[i + 1][0]

          hours = end_time.slice(-8, 2).to_i - start_time.slice(-8, 2).to_i
          mins = end_time.slice(-5, 2).to_i - start_time.slice(-5, 2).to_i
          secs = end_time.slice(-2, 2).to_i - start_time.slice(-2, 2).to_i

          seconds = (hours * 60 * 3600) + (mins * 60) + secs

          @logger.print_current_diapazon(start_time, end_time, seconds) if @is_logger_turn

          @total_time += seconds
        end
      end
    end
  end

  def refresh_root
    Dir.chdir(SETTINGS::ROOT_PATH)
  end
end
