# frozen_string_literal: true

time_start = Time.now

require './time_tracker'
require './service/service_create_folders'
require './service/service_working_csv'
require './service/service_logger'

mode = ARGV[0]


time_tracker = TimeTracker.new(mode \
                             , time_start \
                             , ServiceCreateFolders.new \
                             , ServiceWorkingCsv.new \
                             , ServiceLogger.new)
time_tracker.run
