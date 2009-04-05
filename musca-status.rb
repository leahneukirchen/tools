#!/usr/bin/ruby -s

$title = IO.popen("dzen2 -fg grey90 -bg black -fn terminus-iso8859-1-12 -ta l -w 450 -u", "w")
$title.sync = true

def graph(percent, width=30, height=6)
  "^fg(grey35)^r(#{percent/100.0 * width}x#{height})^fg(grey20)^r(#{(100-percent)/100.0 * width}x#{height})^fg()"
end

fork {
  loop {
    title = `wmtitle`.strip
    desktop = `wmdesk`.strip
    $title.puts "^bg(GreenYellow)^fg(grey20) #{desktop} ^bg()^fg() #{title}"

    sleep 0.2
    exit  if $o
  }
}

exit  if $o

$status = IO.popen("dzen2 -fg grey90 -bg black -fn terminus-iso8859-1-12 -ta r -x 450 -w 350 -u", "w")
$status.sync = true

loop {
  bat = File.read("/proc/acpi/battery/BAT0/state")
  fill = bat[/remaining.*?(\d\d+) mAh/, 1].to_i

  state = case bat
          when /discharging/
            "BATT"
          when /charged/
            "FULL"
          when /charging/
            "LOAD"
          end

  df = `df /`[/(\d+)%/, 1].to_i

  net = `ifconfig -s`

  interfaces = (net.split("\n").find_all { |line|
    line.split[7].to_i > 0   # rx
  }.map { |line|
    line.split.first
  } - ["lo", "wifi0"]).join(" ")

  meminfo = File.read("/proc/meminfo")
  memtotal = meminfo[/MemTotal: *(\d+) kB/, 1].to_i
  memfree = meminfo[/MemFree: *(\d+) kB/, 1].to_i

  free = ((memtotal - memfree)*100 / memtotal).to_i

  $status.puts "#{interfaces}  #{state} #{graph fill}  RAM #{graph free}  DISK #{graph df}  #{Time.now.strftime("%d%b%Y %H:%M").downcase}"

  sleep 2
}

