using Godot;
using ImGuiNET;
using MonkeNet.NetworkMessages;
using MonkeNet.Serializer;
using MonkeNet.Shared;
using System.Collections.Generic;

namespace MonkeNet.Client;

/// <summary>
/// Reads and transmits inputs to the server. Will adjust and send redundant inputs to compensate for bad network conditions.
/// </summary>
[GlobalClass]
public partial class ClientInputManager : InternalClientComponent
{
    private readonly List<ProducedInput> _producedInputs = [];
    private int _lastReceivedTick = 0;

    public IPackableElement GenerateAndTransmitInputs(int currentTick)
    {
        IPackableElement input = MonkeNetConfig.Instance.InputProducer?.GenerateCurrentInput();

        if (input == null)
        {
            return null;
        }

        ProducedInput producedInput = new()
        {
            Tick = currentTick,
            Input = input
        };

        _producedInputs.Add(producedInput);
        SendInputsToServer(currentTick);
        return input;
    }

    // Pack and send current input + all non acked inputs (redundant inputs).
    private void SendInputsToServer(int currentTick)
    {
        var userCmd = new PackedClientInputMessage
        {
            Tick = currentTick,
            Inputs = new IPackableElement[_producedInputs.Count]
        };

        for (int i = 0; i < _producedInputs.Count; i++)
        {
            userCmd.Inputs[i] = _producedInputs[i].Input;
        }

        SendCommandToServer(userCmd, INetworkManager.PacketModeEnum.Unreliable, (int)ChannelEnum.ClientInput);
    }

    // When we receive a snapshot back, we delete all inputs prior/equal to it since those were already processed.
    protected override void OnCommandReceived(IPackableMessage command)
    {
        if (command is GameSnapshotMessage snapshot && snapshot.Tick > _lastReceivedTick)
        {
            _lastReceivedTick = snapshot.Tick;
            _producedInputs.RemoveAll(input => input.Tick <= snapshot.Tick);
        }
    }

    public void DisplayDebugInformation()
    {
        if (ImGui.CollapsingHeader("Input Manager"))
        {
            ImGui.Text($"Redundant Inputs: {_producedInputs.Count}");
        }
    }

    private struct ProducedInput
    {
        public int Tick;
        public IPackableElement Input;
    }
}
