module SiNumberHelper
  def si_number(number, options = {})
    options.symbolize_keys!

    number = begin
      Float(number)
    rescue ArgumentError, TypeError
      return number
    end

    options[:minimum] = 10000 if not options.key?(:minimum)
    options[:precision] = 1 if not options.key?(:precision)

    base = 1000

    prefixes = ['', 'K', 'M', 'B'] # Thousand, Million, Billion

    if number < options[:minimum]
      number_with_precision(number, precision: 0)
    else
      max_exponent = prefixes.size - 1
      exponent     = (Math.log(number) / Math.log(base)).to_i
      exponent     = max_exponent if exponent > max_exponent
      number      /= base ** exponent

      precise = number_with_precision(number, options)
      if options[:precision] > 0
        if precise.to_s.last(options[:precision]).to_i == 0
          precise = number_with_precision(number, precision: 0)
        end
      end
      precise << prefixes[exponent]
    end

  end
end