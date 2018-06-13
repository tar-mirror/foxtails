require 'observable'

module FoxTails
  # Classes which include this module must define an instance method
  # #connect_to_target which establishes the connection between the
  # object and the target. Note that #connect_to_target is called just after
  # create.
  module FTTargeted
    
    # The target arg is either a Fox object or a Proc or Method returning a Fox
    # object
    def init_target(target = nil)
      @target = target
    end
    
    def send_target(*args, &block)
      @target.send(*args, &block) if @target
    end

    def create
      super
      connect_to_target if get_target
    end
    
    # We have to use get_target and retarget because
    # FXRuby uses target and target= in responder.
    def get_target
      if @target.is_a? Proc or @target.is_a? Method
        @target = @target.call
      end
      @target
    end
    
    # Assign this widget to observe another target.
    def retarget(new_target)
      ## only call after create?
      disconnect_from_target if @target
      @target = new_target
      connect_to_target if get_target
    end
  end
  
  # FTStateTargeted replaces the standard tgt,sel mechanism with symbolic
  # variable access. Argument lists are the same as in Fox, but with the
  # tgt, sel arguments replaced with a target object (or proc/method returning
  # an object), a state variable in the target, and possibly additional args.
  #
  # Classes which include this module must define an instance method
  # #target_arg_range which returns the range of positions in the argument
  # list which take the place of tgt,sel.
  module FTStateTargeted
    include FTTargeted
    
    # Should be overridden in each classes that doesn't have the usual tgt,sel
    # mechanism in the original Fox class, such as FXOptionMenu.
    def target_replacements(args); [nil, 0]; end
    
    def initialize(*args)
      range = target_arg_range
      target_args = args[range]
      args[range] = target_replacements(args)
        # Remove non-Fox args and substitute no-op tgt,sel
        # args for FX classes, if needed
      
      super(*args) # we've munged args, so have to pass it in again
      
      init_target(*target_args)
    end

    # state must be name of observable variable in target
    def init_target(target = nil, state = :none)
      super target
      @state = state
      @state_setter = "#{state}=".intern
      @state_getter = "#{state}".intern
      @state_when   = "when_#{state}".intern
      @state_remove_observer = "remove_observer_#{state}".intern
    end
    
    def set_target_state(value)
      send_target(@state_setter, value)
    end
    
    def get_target_state
      send_target(@state_getter)
    end
    
    def when_target_state(pattern, &block)
      send_target(@state_when, pattern, &block)
    end
    
    def disconnect_from_target
      send_target(@state_remove_observer, self)
    end
  end
  
  # The target is an object representing a complex of objects. For example,
  # the target might be an array and the objects might be the members. Or the
  # target might be a tree manager object and the object might be the nodes
  # of the tree.
  module FTComplexStateTargeted
    include FTStateTargeted
    
    # +complex+:: accesses the object which receives requests to operate on and
    #             query the nodes of the complex of objects.
    #
    # +state+::   current selection in the complex of objects.
    #
    def init_target(target = nil, complex = :none, state = :none)
      super target, state
      
      @complex = complex
      @complex_setter = "#{complex}=".intern
      @complex_getter = "#{complex}".intern
      @complex_when   = "when_#{complex}".intern
    end
    
    def set_target_complex(value)
      send_target(@complex_setter, value)
    end
    
    def get_target_complex
      send_target(@complex_getter)
    end
    
    def when_target_complex(pattern, &block)
      send_target(@complex_when, pattern, &block)
    end
  end
  
  module FTListStateTargeted
    include FTComplexStateTargeted
    alias set_target_list   set_target_complex
    alias get_target_list   get_target_complex
    alias when_target_list  when_target_complex
  end
  
  module FTTreeStateTargeted
    include FTComplexStateTargeted
    alias set_target_tree   set_target_complex
    alias get_target_tree   get_target_complex
    alias when_target_tree  when_target_complex
  end
  
end
