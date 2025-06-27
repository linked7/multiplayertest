using Godot;

namespace MonkeNet.Shared;

public class PhysicsUtils
{
    public static readonly float FrameTimeInMsec = (1.0f / Engine.PhysicsTicksPerSecond) * 1000.0f;
    public static readonly float DeltaTime = 1.0f / Engine.PhysicsTicksPerSecond;

    public static readonly Vector3 HorizontalVector = new Vector3(1, 0, 1);
    public static int MsecToTick(int msec)
    {
        return Mathf.CeilToInt(msec / FrameTimeInMsec);
    }

    public static int SecToTick(float sec)
    {
        return Mathf.CeilToInt(sec / DeltaTime);
    }

    /// <summary>
    /// Custom MoveAndSlide() method, will adjust delta accordingly and flush the transform to the PhysicsServer
    /// </summary>
    /// <param name="body"></param>
    public static void MoveAndSlide(CharacterBody3D body)
    {
        bool physicsProcess = Engine.IsInPhysicsFrame();
        double deltaToRemove = physicsProcess ? body.GetPhysicsProcessDeltaTime() :
            body.GetProcessDeltaTime();

        body.Velocity *= PhysicsUtils.DeltaTime / (float)deltaToRemove;
        body.MoveAndSlide();
        body.Velocity /= PhysicsUtils.DeltaTime / (float)deltaToRemove;

        // if (!physicsProcess)
        body.ForceUpdateTransform(); // Flush changes to the PhysicsServer
    }

    public static byte EncodeRadianAngleAsByte(float angle)
    {
        return (byte)((angle / Mathf.Tau) * byte.MaxValue);
    }

    public static float DecodeRadianAngleAsByte(byte angle)
    {
        return (float)angle / byte.MaxValue * Mathf.Tau;
    }
}
