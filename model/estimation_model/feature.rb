class Feature
  attr_reader :analysis_difficulty,
              :implementation_difficulty,
              :testing_difficulty,
              :difficulty,
              :anomalies
  attr_accessor :completed

  def initialize(analysis_difficulty, implementation_difficulty, testing_difficulty)
    @difficulty = analysis_difficulty + implementation_difficulty + testing_difficulty
    @analysis_difficulty = analysis_difficulty
    @implementation_difficulty = implementation_difficulty
    @testing_difficulty = testing_difficulty
    @completed = 0
    @anomalies = []
  end

  def add_anomaly(anomaly)
    @anomalies.push anomaly
  end

  def delete_anomaly(anomaly)
    @anomalies = @anomalies.select {|a| a != anomaly}
  end
end
