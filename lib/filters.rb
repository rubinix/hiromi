class Filter
end

class LowerFilter

  def execute(data)
    data.downcase
  end

end

class LengthFilter

  def execute(data)
    data.length
  end

end
