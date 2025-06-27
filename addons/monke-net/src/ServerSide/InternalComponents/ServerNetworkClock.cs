using Godot;
using ImGuiNET;
using MonkeNet.NetworkMessages;
using MonkeNet.Serializer;
using MonkeNet.Shared;

namespace MonkeNet.Server;

[GlobalClass]
public partial class ServerNetworkClock : InternalServerComponent
{
    [Signal] public delegate void NetworkProcessTickEventHandler(double delta);

    [Export] private int _netTickrate = 30;
    private double _netTickCounter = 0;
    private int _currentTick = 0;

    public override void _Ready()
    {
        base._Ready();
    }

    public override void _Process(double delta)
    {
        SolveSendNetworkTickEvent(delta);
    }

    public int ProcessTick()
    {
        _currentTick += 1;
        return _currentTick;
    }

    public int GetNetworkTickRate()
    {
        return _netTickrate;
    }

    private void SolveSendNetworkTickEvent(double delta)
    {
        _netTickCounter += delta;
        if (_netTickCounter >= (1.0 / _netTickrate))
        {
            EmitSignal(SignalName.NetworkProcessTick, _netTickCounter);
            _netTickCounter = 0;
        }
    }

    // When we receive a sync packet from a Client, we return it with the current Clock data
    protected override void OnCommandReceived(int clientId, IPackableMessage command)
    {
        if (command is ClockSyncMessage sync)
        {
            sync.ServerTime = _currentTick;
            SendCommandToClient(clientId, sync, INetworkManager.PacketModeEnum.Unreliable, 1);
        }
    }

    public void DisplayDebugInformation()
    {
        if (ImGui.CollapsingHeader("Clock Information"))
        {
            ImGui.Text($"Network Tickrate {GetNetworkTickRate()}hz");
            ImGui.Text($"Current Tick {_currentTick}");
        }
    }
}
