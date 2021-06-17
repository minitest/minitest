# frozen_string_literal: true

module Minitest
  def self.plugin_parallel_init options # :nodoc:
    warn "DEPRECATED: use MT_CPU instead of N for parallel test runs" if ENV["N"]
    n_threads = (ENV["MT_CPU"] || ENV["N"] || 2).to_i
    self.parallel_executor = Parallel::Executor.new n_threads
  end
end
