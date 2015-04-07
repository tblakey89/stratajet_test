class NotomParser

  DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

  def initialize data
    @unparsed_data = split_data data
  end

  def generate_output
    output_data = []
    valid_notom_data.each do |data|
      output_data << {
        icao: find_icao(data),
        opening_times: find_times(data),
      }
    end
    output_data
  end

private

  def valid_notom_data
    valid_data = []
    @unparsed_data.each do |data|
      # valid data contains the string used in the RegEx
      valid_data << data if data.match(/AERODROME HOURS OF OPS\/SERVICE/)
    end
    valid_data
  end

  def split_data data
    data.split("\r\n\r\n")
  end

  def find_icao data
    # get the string between A) and B) in the notom data
    data.match(/(A\))(.*?)(B\))/m)[2].squish.strip
  end

  def find_times data
    current_index = 0
    time_array = []
    times = notom_description data
    # for each day get the opening times
    while current_index < DAYS.length do
      multi_day_index = times.index(DAYS[current_index] + "-")
      if !multi_day_index.nil?
        # find the end day index of the multi-day opening time
        till_day = DAYS.index(times[(multi_day_index + 4)..(multi_day_index + 6)])
        time_array = multi_day_opening_times(times, time_array, current_index, till_day)
        current_index = till_day + 1
      else
        time_array << opening_times(times, current_index)
        current_index += 1
      end
    end
    time_array
  end

  def opening_times times, current_index
    string_index = times.index(DAYS[current_index])
    # use the index in the string where the day was found to get the times
    open_or_closed(times[(string_index+3)..-1].match(/[\d\s\,\-]+(?=[A-Z])/m)[0])
  end

  def multi_day_opening_times times, time_array, current_index, till_day_index
    string_index = times.index(DAYS[current_index])
    # use the index of the string to find what the opening times are
    opening_times = times[(string_index+7)..-1].match(/[\d\s\,\-]+(?=[A-Z])/m)[0]
    # go through each day in multi day opening time, and add to times array
    while current_index <= till_day_index do
      time_array[current_index] = open_or_closed(opening_times)
      current_index += 1
    end
    time_array
  end

  def notom_description notom
    # get the line which contains the opening times from the notom data
    notom.match(/AERODROME HOURS OF OPS\/SERVICE(.*?)CREATED/m)[0].squish
  end

  def open_or_closed time
    if time.strip[0] =~ /[[:digit:]]/
      time.strip.gsub(/,/, "").gsub(/\s/, "\n")
    else
      "CLOSED"
    end
  end

end
