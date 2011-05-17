# Reopen Net::SSH to allow for a "realtime" ssh run that prints out stdout
# immediately upon receipt, so you can interactively watch the results.
class Net::SSH::Connection::Session
  def exec_realtime(cmd)
    open_channel do |channel|
      channel.exec(cmd) do |ch, success|
        abort "could not execute command: #{cmd}" unless success

        channel.on_data do |ch, data|
          puts "#{data}"
        end

        channel.on_extended_data do |ch, type, data|
          warn "ERROR: #{data}"
        end
      end
    end
    loop
  end
end