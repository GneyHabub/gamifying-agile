require_relative './development_process'
require_relative './feature'
require_relative './models/scrum'

class Project
  attr_reader :team,
              :development_process,
              :features,
              :ticks_passed,
              :statistics

  def initialize(team, stage, features)
    @development_process = DevelopmentProcess.new stage
    @team = team
    @features = features
    @ticks_passed = 0
    @statistics = [[], []]
  end

  def get_percentage_complete
    completed = @features.select {|f| f.completed == f.difficulty}.length
    completed.to_f/@features.length
  end

  def get_task_type_distribution
    analysis = @development_process.backlog.select {|t| t.is_a? RequirementAnalysisTask}.length
    implementation = @development_process.backlog.select {|t| t.is_a? ImplementationTask}.length
    testing = @development_process.backlog.select {|t| t.is_a? TestingTask}.length
    [analysis, implementation, testing]
  end

  def tick
    @development_process.tick self
    if rand < 0.1
      delete_tasks = rand 0..2
      delete_tasks.times do
        @features.delete_at(rand(@features.length))
      end
      add_tasks = rand 0..2
      @features = @features + Array.new(add_tasks) {|i| Feature.new rand(1..5), rand(1..5), rand(1..5)}
    end
    @ticks_passed += 1
  end

  def simulate
    until @development_process.terminated
      self.tick
      @statistics[0].push self.get_percentage_complete
      @statistics[1].push self.get_task_type_distribution
    end
    @statistics
  end
end