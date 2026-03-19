/**
 * Created on
 *      2025/9/17
 *      2025/9/4
 *      2025/8/29
 * ----------------
 * package MiniST
 *      module AdamOptimizer
 */

package MiniST

import std.math.*

public class AdamOptimizerConfig {
    public AdamOptimizerConfig(
        // Adam args
        let adamBeta1!: Float32 = 0.9,
        let adamBeta2!: Float32 = 0.999,
        let adamEpsilon!: Float32 = 1e-8
    ) {}
}

public class AdamOptimizer {
    // w1的一阶/二阶动量
    public var mWeightInputToHidden: Matrix<Float32> = Matrix<Float32>()
    public var vWeightInputToHidden: Matrix<Float32> = Matrix<Float32>()
    // b1的一阶/二阶动量
    public var mBiasHiddenLayer: Array<Float32> = Array<Float32>()
    public var vBiasHiddenLayer: Array<Float32> = Array<Float32>()
    // w2的一阶/二阶动量
    public var mWeightHiddenToOutput: Matrix<Float32> = Matrix<Float32>()
    public var vWeightHiddenToOutput: Matrix<Float32> = Matrix<Float32>()
    // b2的一阶/二阶动量
    public var mBiasOutputLayer: Array<Float32> = Array<Float32>()
    public var vBiasOutputLayer: Array<Float32> = Array<Float32>()
    // Adam迭代次数（用于偏差修正）
    public var adamIteration: Float32 = 0.0

    // config able
    public var adamBeta1: Float32 // Adam一阶动量衰减系数（默认0.9）
    public var adamBeta2: Float32 // Adam二阶动量衰减系数（默认0.999）
    public var adamEpsilon: Float32 // Adam数值稳定项（默认1e-8）

    public init(inputLayerSize: Int32, hiddenLayerSize: Int32, outputLayerSize: Int32,
        config!: AdamOptimizerConfig = AdamOptimizerConfig()) {
        // 初始化参数
        this.adamBeta1 = config.adamBeta1
        this.adamBeta2 = config.adamBeta2
        this.adamEpsilon = config.adamEpsilon
        // 初始化Adam动量变量（全部初始化为0）
        this.mWeightInputToHidden = this.initZeroMatrix(inputLayerSize, hiddenLayerSize)
        this.vWeightInputToHidden = this.initZeroMatrix(inputLayerSize, hiddenLayerSize)
        this.mBiasHiddenLayer = Array<Float32>(Int64(hiddenLayerSize), item: 0.0)
        this.vBiasHiddenLayer = Array<Float32>(Int64(hiddenLayerSize), item: 0.0)
        this.mWeightHiddenToOutput = this.initZeroMatrix(hiddenLayerSize, outputLayerSize)
        this.vWeightHiddenToOutput = this.initZeroMatrix(hiddenLayerSize, outputLayerSize)
        this.mBiasOutputLayer = Array<Float32>(Int64(outputLayerSize), item: 0.0)
        this.vBiasOutputLayer = Array<Float32>(Int64(outputLayerSize), item: 0.0)
    }

    private func initZeroMatrix(row: Int32, col: Int32): Matrix<Float32> {
        return Matrix<Float32>(Int64(row)){ i=> Array<Float32>(Int64(col), item: 0.0) }
    }

    public func updateWeightHiddenToOutput(gradient: Float32, iIndex: Int64, jIndex: Int64) {
        // Adam一阶动量更新：m = β1*m_prev + (1-β1)*gradient
        mWeightHiddenToOutput[iIndex][jIndex] = (adamBeta1 * mWeightHiddenToOutput[iIndex][jIndex]) + ((1.0 - adamBeta1) *
            gradient)
        // Adam二阶动量更新：v = β2*v_prev + (1-β2)*gradient²
        vWeightHiddenToOutput[iIndex][jIndex] = (adamBeta2 * vWeightHiddenToOutput[iIndex][jIndex]) + ((1.0 - adamBeta2) *
            gradient * gradient)
        // 偏差修正
        return (mWeightHiddenToOutput[iIndex][jIndex] / (1.0 - pow(adamBeta1, adamIteration)),
            vWeightHiddenToOutput[iIndex][jIndex] / (1.0 - pow(adamBeta2, adamIteration)))
    }

    public func updateWeightInputToHidden(gradient: Float32, iIndex: Int64, jIndex: Int64) {
        // Adam一阶动量更新
        mWeightInputToHidden[iIndex][jIndex] = (adamBeta1 * mWeightInputToHidden[iIndex][jIndex]) + ((1.0 - adamBeta1) *
            gradient)
        // Adam二阶动量更新
        vWeightInputToHidden[iIndex][jIndex] = (adamBeta2 * vWeightInputToHidden[iIndex][jIndex]) + ((1.0 - adamBeta2) *
            gradient * gradient)
        // 偏差修正
        return (mWeightInputToHidden[iIndex][jIndex] / (1.0 - pow(adamBeta1, adamIteration)),
            vWeightInputToHidden[iIndex][jIndex] / (1.0 - pow(adamBeta2, adamIteration)))
    }

    public func updateBiaOutputLayer(gradient: Float32, jIndex: Int64) {
        mBiasOutputLayer[jIndex] = (adamBeta1 * mBiasOutputLayer[jIndex]) + ((1.0 - adamBeta1) * gradient)
        vBiasOutputLayer[jIndex] = (adamBeta2 * vBiasOutputLayer[jIndex]) + ((1.0 - adamBeta2) * gradient * gradient)
        // 偏差修正
        return (mBiasOutputLayer[jIndex] / (1.0 - pow(adamBeta1, adamIteration)), vBiasOutputLayer[jIndex] / (1.0 - pow(
                adamBeta2, adamIteration)))
    }

    public func updateBiasHiddenLayer(gradient: Float32, jIndex: Int64) {
        // Adam动量更新
        mBiasHiddenLayer[jIndex] = (adamBeta1 * mBiasHiddenLayer[jIndex]) + ((1.0 - adamBeta1) * gradient)
        vBiasHiddenLayer[jIndex] = (adamBeta2 * vBiasHiddenLayer[jIndex]) + ((1.0 - adamBeta2) * gradient * gradient)
        // 偏差修正
        return (mBiasHiddenLayer[jIndex] / (1.0 - pow(adamBeta1, adamIteration)), vBiasHiddenLayer[jIndex] / (1.0 - pow(
                adamBeta2, adamIteration)))
    }
}
