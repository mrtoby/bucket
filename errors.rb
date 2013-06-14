#!/usr/bin/env ruby

class TransactionFailedError < StandardError
  attr_reader :version_id_after_rollback, :exception
  def initialize(version_id_after_rollback, exception)
    super("Failed to perform transaction, rolled back to #{version_id_after_rollback}")
    @version_id_after_rollback = version_id_after_rollback
    @exception = exception
  end
end

class IllegalStateError < StandardError; end
