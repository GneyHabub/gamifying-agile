require_relative './task'
require_relative './anomaly'

ANOMALIES_REGULATOR = 10

class Action
  attr_reader :team_member,
              :task_class,
              :task,
              :time_spent,
              :done

  def initialize(team_member, task)
    @team_member = team_member
    team_member.is_busy = true
    @task = task
    task.is_worked_on = true
    @time_spent = 0
    @done = false
  end

  def tick(process)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class RequirementAnalysisAction < Action
  def initialize(team_member, task)
    super
    @task_class = RequirementAnalysisTask
  end

  def tick(process)
    @time_spent += 1
    #generate anomalies
    probability = 0
    if @task.required_skills.each do |skill|
        tm_skill = @team_member.skills.find {|s| s.name == skill.name}
        if tm_skill.nil?
          probability += 0.5
        else
          probability += (skill.level - tm_skill.level).fdiv ANOMALIES_REGULATOR
        end
      end
    end
    probability = [[probability, 0].max, 1].min
    if rand <= probability
      @task.feature.add_anomaly(Anomaly.new @task.feature, [Skill.new('analysis', rand(1..5))])
    end
    if @time_spent == @task.time_required
      process.backlog.delete @task
      process.backlog.push ImplementationTask.new(@task.feature, [Skill.new('development', rand(1..10))])
      @task.feature.completed += @task.feature.analysis_difficulty
      @team_member.is_busy = false
      @done = true
    end
  end
end

class ImplementationAction < Action
  def initialize(team_member, task)
    super
    @task_class = ImplementationTask
  end

  def tick(process)
    @time_spent += 1
    #generate anomalies
    probability = 0
    if @task.required_skills.each do |skill|
        tm_skill = @team_member.skills.find {|s| s.name == skill.name}
        if tm_skill.nil?
          probability += 0.5
        else
          probability += (skill.level - tm_skill.level).fdiv ANOMALIES_REGULATOR
        end
      end
    end
    probability = [[probability, 0].max, 1].min
    if rand <= probability
      @task.feature.add_anomaly(Anomaly.new @task.feature, [Skill.new('development', rand(1..5))])
    end
    if @time_spent == @task.time_required
      process.backlog.delete @task
      process.backlog.push TestingTask.new(@task.feature, [Skill.new('testing', rand(1..10))])
      @task.feature.completed += @task.feature.implementation_difficulty
      @team_member.is_busy = false
      @done = true
    end
  end
end

class TestingAction < Action
  def initialize(team_member, task)
    super
    @task_class = TestingTask
  end

  def tick(process)
    @time_spent += 1
    #generate anomalies
    probability = 0
    if @task.required_skills.each do |skill|
      tm_skill = @team_member.skills.find {|s| s.name == skill.name}
      if tm_skill.nil?
        probability += 0.5
      else
        probability += (skill.level - tm_skill.level).fdiv ANOMALIES_REGULATOR
      end
    end
    end
    probability = [[probability, 0].max, 1].min
    if rand <= probability
      @task.feature.add_anomaly(Anomaly.new @task.feature, [Skill.new('testing', rand(1..5))])
    end

    #find anomalies
    unless @task.feature.anomalies.length == 0
      testing_skill = @team_member.skills.find {|s| s.name == "testing"}
        unless testing_skill.nil?
          probability = testing_skill.level.fdiv 10
          if rand <= probability
            process.find_anomaly(@task.feature.anomalies[0])
            @task.feature.delete_anomaly(@task.feature.anomalies[0])
          end
        end
    end
    if @time_spent == @task.time_required
      process.backlog.delete @task
      @task.feature.completed += @task.feature.testing_difficulty
      @team_member.is_busy = false
      @done = true
    end
  end
end

class AnomalyFixingAction < Action
  def initialize(team_member, task)
    super
    @task_class = Anomaly
  end

  def tick(process)
    @time_spent += 1
    if @time_spent == @task.time_required
      process.backlog.delete @task
      @team_member.is_busy = false
      @done = true
    end
  end
end
