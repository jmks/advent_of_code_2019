defmodule Day07 do
  @moduledoc """
--- Day 7: Amplification Circuit ---

Based on the navigational maps, you're going to need to send more power to your ship's thrusters to reach Santa in time. To do this, you'll need to configure a series of amplifiers already installed on the ship.

There are five amplifiers connected in series; each one receives an input signal and produces an output signal. They are connected such that the first amplifier's output leads to the second amplifier's input, the second amplifier's output leads to the third amplifier's input, and so on. The first amplifier's input value is 0, and the last amplifier's output leads to your ship's thrusters.

    O-------O  O-------O  O-------O  O-------O  O-------O
0 ->| Amp A |->| Amp B |->| Amp C |->| Amp D |->| Amp E |-> (to thrusters)
    O-------O  O-------O  O-------O  O-------O  O-------O

The Elves have sent you some Amplifier Controller Software (your puzzle input), a program that should run on your existing Intcode computer. Each amplifier will need to run a copy of the program.

When a copy of the program starts running on an amplifier, it will first use an input instruction to ask the amplifier for its current phase setting (an integer from 0 to 4). Each phase setting is used exactly once, but the Elves can't remember which amplifier needs which phase setting.

The program will then call another input instruction to get the amplifier's input signal, compute the correct output signal, and supply it back to the amplifier with an output instruction. (If the amplifier has not yet received an input signal, it waits until one arrives.)

Your job is to find the largest output signal that can be sent to the thrusters by trying every possible combination of phase settings on the amplifiers. Make sure that memory is not shared or reused between copies of the program.

For example, suppose you want to try the phase setting sequence 3,1,2,4,0, which would mean setting amplifier A to phase setting 3, amplifier B to setting 1, C to 2, D to 4, and E to 0. Then, you could determine the output signal that gets sent from amplifier E to the thrusters with the following steps:

Start the copy of the amplifier controller software that will run on amplifier A. At its first input instruction, provide it the amplifier's phase setting, 3. At its second input instruction, provide it the input signal, 0. After some calculations, it will use an output instruction to indicate the amplifier's output signal.
Start the software for amplifier B. Provide it the phase setting (1) and then whatever output signal was produced from amplifier A. It will then produce a new output signal destined for amplifier C.
Start the software for amplifier C, provide the phase setting (2) and the value from amplifier B, then collect its output signal.
Run amplifier D's software, provide the phase setting (4) and input value, and collect its output signal.
Run amplifier E's software, provide the phase setting (0) and input value, and collect its output signal.
The final output signal from amplifier E would be sent to the thrusters. However, this phase setting sequence may not have been the best one; another sequence might have sent a higher signal to the thrusters.

Here are some example programs:

Max thruster signal 43210 (from phase setting sequence 4,3,2,1,0):

3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0
Max thruster signal 54321 (from phase setting sequence 0,1,2,3,4):

3,23,3,24,1002,24,10,24,1002,23,-1,23,
101,5,23,23,1,24,23,23,4,23,99,0,0
Max thruster signal 65210 (from phase setting sequence 1,0,4,3,2):

3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0

Try every combination of phase settings on the amplifiers. What is the highest signal that can be sent to the thrusters?

--- Part Two ---
It's no good - in this configuration, the amplifiers can't generate a large enough output signal to produce the thrust you'll need. The Elves quickly talk you through rewiring the amplifiers into a feedback loop:

      O-------O  O-------O  O-------O  O-------O  O-------O
0 -+->| Amp A |->| Amp B |->| Amp C |->| Amp D |->| Amp E |-.
   |  O-------O  O-------O  O-------O  O-------O  O-------O |
   |                                                        |
   '--------------------------------------------------------+
                                                            |
                                                            v
                                                     (to thrusters)
Most of the amplifiers are connected as they were before; amplifier A's output is connected to amplifier B's input, and so on. However, the output from amplifier E is now connected into amplifier A's input. This creates the feedback loop: the signal will be sent through the amplifiers many times.

In feedback loop mode, the amplifiers need totally different phase settings: integers from 5 to 9, again each used exactly once. These settings will cause the Amplifier Controller Software to repeatedly take input and produce output many times before halting. Provide each amplifier its phase setting at its first input instruction; all further input/output instructions are for signals.

Don't restart the Amplifier Controller Software on any amplifier during this process. Each one should continue receiving and sending signals until it halts.

All signals sent or received in this process will be between pairs of amplifiers except the very first signal and the very last signal. To start the process, a 0 signal is sent to amplifier A's input exactly once.

Eventually, the software on the amplifiers will halt after they have processed the final loop. When this happens, the last output signal from amplifier E is sent to the thrusters. Your job is to find the largest output signal that can be sent to the thrusters using the new phase settings and feedback loop arrangement.

Here are some example programs:

Max thruster signal 139629729 (from phase setting sequence 9,8,7,6,5):
3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5

Max thruster signal 18216 (from phase setting sequence 9,7,8,5,6):
3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10

Try every combination of the new phase settings on the amplifier feedback loop. What is the highest signal that can be sent to the thrusters?

"""
  defmodule IntcodeState do
    defstruct state: :running, code: [], instruction_pointer: 0, inputs: [], outputs: []

    def diagnostic_code(state) do
      cond do
        Enum.any?(state.outputs) ->
          hd(state.outputs)
        Enum.any?(state.inputs) ->
          hd(state.inputs)
        true ->
          IO.puts "Error reading output from current state:"
          IO.inspect state
          raise "No output"
      end
    end

    def next_opcode_and_modes(state) do
      opcode_mask = next_instruction(state)
      digits = Integer.digits(opcode_mask) |> Enum.reverse

      opcode = digits |> Enum.take(2) |> Enum.reverse |> normalize_opcode
      # TODO: normalize modes to symbols
      modes = digits |> Enum.drop(2) |> normalize_modes

      {opcode, modes}
    end

    def next_args(state, number) when is_integer(number) do
      Enum.drop(state.code, state.instruction_pointer + 1) |> Enum.take(number)
    end

    defp next_instruction(state) do
      Enum.drop(state.code, state.instruction_pointer) |> hd
    end

    defp normalize_opcode([o]), do: normalize_opcode([0, o])
    defp normalize_opcode([0, 1]), do: :add
    defp normalize_opcode([0, 2]), do: :multiply
    defp normalize_opcode([0, 3]), do: :save_input
    defp normalize_opcode([0, 4]), do: :write_output
    defp normalize_opcode([0, 5]), do: :jump_if_true
    defp normalize_opcode([0, 6]), do: :jump_if_false
    defp normalize_opcode([0, 7]), do: :less_than
    defp normalize_opcode([0, 8]), do: :equal
    defp normalize_opcode([9, 9]), do: :abort

    defp normalize_modes([]), do: {0, 0, 0}
    defp normalize_modes([m]), do: {m, 0, 0}
    defp normalize_modes([m, n]), do: {m, n, 0}
    defp normalize_modes([m, n, o]), do: {m, n, o}
  end

  @max_opcode_args 3

  def intcode(code, inputs), do: do_intcode(%IntcodeState{code: code, inputs: inputs})

  defp do_intcode(state = %IntcodeState{state: :running}) do
    new_state = process(state)

    case new_state.state do
      :halted ->
        {:halted, IntcodeState.diagnostic_code(new_state)}
      :wrote_output ->
        {:wrote_output, IntcodeState.diagnostic_code(new_state), new_state}
      :running ->
        do_intcode(new_state)
    end
  end

  defp process(state) do
    {opcode, modes} = IntcodeState.next_opcode_and_modes(state)
    args = IntcodeState.next_args(state, @max_opcode_args)

    {ip_update, new_code, new_inputs, new_outputs} = eval(
      opcode,
      modes,
      args,
      state.inputs,
      state.outputs, # TODO: this probably isn't necessary
      state.code
    )

    new_instruction_pointer = update_instruction_pointer(ip_update, state.instruction_pointer + 1)
    new_state =
      case opcode do
        :write_output -> :wrote_output
        :abort -> :halted
        _ -> :running
      end

    %IntcodeState{
      state: new_state,
      code: new_code,
      instruction_pointer: new_instruction_pointer,
      inputs: new_inputs,
      outputs: new_outputs
    }
  end

  defp update_instruction_pointer({:inc, value}, ip), do: value + ip
  defp update_instruction_pointer({:set, value}, _ip), do: value

  defp eval(opcode, modes, args, inputs, outputs, codes)

  defp eval(:add, {mode1, mode2, _}, [arg1, arg2, arg3 | _], inputs, outputs, codes) do
    new_value = value_of(codes, mode1, arg1) + value_of(codes, mode2, arg2)
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:multiply, {mode1, mode2, _}, [arg1, arg2, arg3 | _], inputs, outputs, codes) do
    new_value = value_of(codes, mode1, arg1) * value_of(codes, mode2, arg2)
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:save_input, _modes, [index | _], [input | new_inputs], outputs, codes) do
    new_codes = List.replace_at(codes, index, input)

    {{:inc, 1}, new_codes, new_inputs, outputs}
  end

  defp eval(:write_output, {mode, _, _}, [index | _], inputs, outputs, codes) do
    value = value_of(codes, mode, index)

    {{:inc, 1}, codes, inputs, [value | outputs]}
  end

  defp eval(:jump_if_true, {mode1, mode2, _}, [arg1, arg2 | _], inputs, outputs, codes) do
    if value_of(codes, mode1, arg1) == 0 do
      # no-op
      {{:inc, 2}, codes, inputs, outputs}
    else
      new_ip = value_of(codes, mode2, arg2)

      {{:set, new_ip}, codes, inputs, outputs}
    end
  end

  defp eval(:jump_if_false, {mode1, mode2, _}, [arg1, arg2 | _], inputs, outputs, codes) do
    if value_of(codes, mode1, arg1) == 0 do
      new_ip = value_of(codes, mode2, arg2)

      {{:set, new_ip}, codes, inputs, outputs}
    else
      # no-op
      {{:inc, 2}, codes, inputs, outputs}
    end
  end

  defp eval(:less_than, {mode1, mode2, _}, [arg1, arg2, arg3| _], inputs, outputs, codes) do
    new_value = if value_of(codes, mode1, arg1) < value_of(codes, mode2, arg2), do: 1, else: 0
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:equal, {mode1, mode2, _}, [arg1, arg2, arg3| _], inputs, outputs, codes) do
    new_value = if value_of(codes, mode1, arg1) == value_of(codes, mode2, arg2), do: 1, else: 0
    new_codes = List.replace_at(codes, arg3, new_value)

    {{:inc, 3}, new_codes, inputs, outputs}
  end

  defp eval(:abort, _modes, _args, inputs, outputs, codes) do
    {{:inc, length(codes)}, codes, inputs, outputs}
  end

  defp value_of(codes, 0, index), do: Enum.at(codes, index)
  defp value_of(_codes, 1, value), do: value

  def run_amplification_circuit(code, [a, b, c, d, e]) do
    output1 = run_until_halted(code, [a, 0])
    output2 = run_until_halted(code, [b, output1])
    output3 = run_until_halted(code, [c, output2])
    output4 = run_until_halted(code, [d, output3])
    output5 = run_until_halted(code, [e, output4])

    output5
  end

  def run_feedback_circuit(code, [a, b, c, d, e]) do
    amplifiers = [
      %IntcodeState{code: code, inputs: [a]},
      %IntcodeState{code: code, inputs: [b]},
      %IntcodeState{code: code, inputs: [c]},
      %IntcodeState{code: code, inputs: [d]},
      %IntcodeState{code: code, inputs: [e]}
    ]

    do_run_feedback_circuit(amplifiers, 0)
  end

  defp do_run_feedback_circuit([], output), do: output

  defp do_run_feedback_circuit([state | rest], new_input) do
    run_state = %{state | state: :running, outputs: [], inputs: state.inputs ++ [new_input]}

    case do_intcode(run_state) do
      {:halted, output} ->
        do_run_feedback_circuit(rest, output)

      {:wrote_output, output, new_state} ->
        do_run_feedback_circuit(rest ++ [new_state], output)
    end
  end

  defp run_until_halted(code, inputs), do: do_run_until_halted(%IntcodeState{code: code, inputs: inputs})

  defp do_run_until_halted(state) do
    case do_intcode(state) do
      {:halted, diagnostic_code} ->
        diagnostic_code
      {:wrote_output, _, output_state} ->
        new_state = %{output_state | state: :running}
        do_run_until_halted(new_state)
    end
  end

  def max_amplification(code, max) when is_integer(max) do
    0..max
    |> Enum.into([])
    |> combinations
    |> Enum.map(fn phase_settings -> run_amplification_circuit(code, phase_settings) end)
    |> Enum.max
  end

  def max_amplification_with_feedback(code, phase_settings_range) do
    phase_settings_range
    |> Enum.into([])
    |> combinations
    |> Enum.map(fn phase_settings -> run_feedback_circuit(code, phase_settings) end)
    |> Enum.max
  end

  def combinations([]), do: []
  def combinations([x | []]), do: [x]
  def combinations([x, y | []]), do: [[x, y], [y, x]]
  def combinations(list) do
    Enum.flat_map(list, fn x ->
      rest = combinations(List.delete(list, x))

      Enum.map(rest, fn y -> [x | y] end)
    end)
  end
end
