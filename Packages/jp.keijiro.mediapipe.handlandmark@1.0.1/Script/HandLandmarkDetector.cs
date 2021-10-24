using Unity.Barracuda;
using UnityEngine;

namespace MediaPipe.HandLandmark {

//
// Implementation of the hand landmark detector class
//
public sealed partial class HandLandmarkDetector : System.IDisposable
{
    #region Private objects

    ResourceSet _resources;
    ComputeBuffer _preBuffer;
    ComputeBuffer _postBuffer;
    // ComputeBuffer _outBuffer;
    IWorker _worker;

    void AllocateObjects()
    {
        var model = ModelLoader.Load(_resources.model);
        _preBuffer = new ComputeBuffer(ImageSize * ImageSize * 3, sizeof(float));
        // _outBuffer = new ComputeBuffer(ImageSize * ImageSize * 3, sizeof(float));
        _postBuffer = new ComputeBuffer(VertexCount + 1, sizeof(float) * 4);
        
        _worker = model.CreateWorker();    //  10

        // _worker = WorkerFactory.CreateWorker(WorkerFactory.Type.ComputePrecompiled, model);
        // ComputePrecompiled     15    15      10
        // Compute                23    10      9
        // ComputeRef             15    7       10
        // CSharpBurst            4     3       3
        // CSharp                 1     1       1
        // CSharpRef       wtf is wrong with this shit
    }

    void DeallocateObjects()
    {
        _preBuffer?.Dispose();
        _preBuffer = null;

        _postBuffer?.Dispose();
        _postBuffer = null;

        // _outBuffer?.Dispose();
        // _outBuffer = null;

        _worker?.Dispose();
        _worker = null;
    }

    #endregion

    #region Neural network inference function

    ComputeBuffer Preprocess(Texture source)
    {
        var pre = _resources.preprocess;
        pre.SetTexture(0, "_Texture", source);
        pre.SetBuffer(0, "_Tensor", _preBuffer);
        pre.Dispatch(0, ImageSize / 8, ImageSize / 8, 1);
        return _preBuffer;
    }

    // ComputeBuffer PeekOutputBufferAltered(string name) 
    // {
    //     _outBuffer.SetData(_worker.PeekOutput(name).data.Download(_worker.PeekOutput(name).shape));
    //     return _outBuffer;
    // }

    void RunModel(ComputeBuffer input)
    {
        // Run the BlazeFace model.
        using (var tensor = new Tensor(1, ImageSize, ImageSize, 3, input))
            _worker.Execute(tensor);

        // Postprocessing
        var post = _resources.postprocess;
        post.SetBuffer(0, "_Landmark", _worker.PeekOutputBuffer("Identity"));
        post.SetBuffer(0, "_Score", _worker.PeekOutputBuffer("Identity_1"));
        post.SetBuffer(0, "_Handedness", _worker.PeekOutputBuffer("Identity_2"));
        post.SetBuffer(0, "_Output", _postBuffer);
        post.Dispatch(0, 1, 1, 1);

        // Read cache invalidation
        _postRead = false;
    }

    #endregion

    #region GPU to CPU readback

    Vector4[] _postReadCache = new Vector4[VertexCount + 1];
    bool _postRead;

    Vector4[] PostReadCache
      => _postRead ? _postReadCache : UpdatePostReadCache();

    Vector4[] UpdatePostReadCache()
    {
        _postBuffer.GetData(_postReadCache, 0, 0, VertexCount + 1);
        _postRead = true;
        return _postReadCache;
    }

    #endregion
}

} // namespace MediaPipe.HandLandmark
