/**
 * Created on
 *      2025/9/17
 *      2025/9/4
 *      2025/8/29
 * ----------------
 * package MiniST
 *      module BPNetwork
 */

package MiniST

import std.random.*
import std.math.*

// 3. 优化的BP神经网络（批次训练）
class BPNetwork {
    // 矩阵计算并发块大小
    public static let chunkSize: Int64 = 20
    // 1. 权重和偏置（原逻辑保留）
    private var weightInputToHidden: Matrix<Float32> = Matrix<Float32>() // 784×500（输入→隐藏）
    private var biasHiddenLayer: Array<Float32> = Array<Float32>() // 500（隐藏层偏置）
    private var weightHiddenToOutput: Matrix<Float32> = Matrix<Float32>() // 500×10（隐藏→输出）
    private var biasOutputLayer: Array<Float32> = Array<Float32>() // 10（输出层偏置）

    // 2. Adam优化器
    private var optimizer: AdamOptimizer

    // 3. 网络超参数（新增Adam默认超参数）
    // 4. 初始化：新增Adam状态变量初始化
    public BPNetwork(
        private let inputLayerSize: Int32,
        private let hiddenLayerSize: Int32,
        private let outputLayerSize: Int32,
        private let learningRate: Float32,
        private let regularization: Float32
    ) {
        this.optimizer = AdamOptimizer(inputLayerSize, hiddenLayerSize, outputLayerSize)

        // 初始化权重（Xavier初始化，原逻辑保留）
        this.weightInputToHidden = MatrixUtils.randomInit(inputLayerSize, hiddenLayerSize)
        this.weightHiddenToOutput = MatrixUtils.randomInit(hiddenLayerSize, outputLayerSize)
        // 初始化偏置（原逻辑保留）
        this.biasHiddenLayer = Array<Float32>(Int64(hiddenLayerSize), item: 0.01)
        this.biasOutputLayer = Array<Float32>(Int64(outputLayerSize), item: 0.01)
    }

    // 批次前向传播
    func forwardBatch(batch: Matrix<Float32>): (Matrix<Float32>, Matrix<Float32>) {
        // 隐藏层：batch×w1 + b1 → ReLU
        let hiddenPre = MatrixUtils.batchVecMatMul(batch, this.weightInputToHidden)
        let hiddenAct = MatrixUtils.batchAddBias(hiddenPre, this.biasHiddenLayer)
        let hiddenOut = MatrixUtils.batchRelu(hiddenAct)

        // 输出层：hidden×w2 + b2
        let outputPre = MatrixUtils.batchVecMatMul(hiddenOut, this.weightHiddenToOutput)
        let outputAct = MatrixUtils.batchAddBias(outputPre, this.biasOutputLayer)

        return (hiddenOut, outputAct)
    }

    // 计算批次损失
    func computeBatchLoss(output: Matrix<Float32>, labels: Matrix<Float32>): Float32 {
        let m = Float32(output.size)
        let softmaxOut = MatrixUtils.batchSoftmax(output)
        let epsilon = 1e-10
        var totalLoss = Float32(0.0)

        // 交叉熵损失
        for (i in 0..=output.size - 1) {
            let outRow = softmaxOut[i]
            let labelRow = labels[i]
            for (jIdx in 0..=Int64(this.outputLayerSize - 1)) {
                let prob = if (outRow[jIdx] < Float32(epsilon)) {
                    Float32(epsilon)
                } else {
                    outRow[jIdx]
                }
                totalLoss -= labelRow[jIdx] * log(prob)
            }
        }

        // L2正则化（平均到每个样本）
        var regLoss = Float32(0.0)
        for (i in 0..=Int64(this.inputLayerSize - 1)) {
            for (j in 0..=Int64(this.hiddenLayerSize - 1)) {
                regLoss += weightInputToHidden[i][j] * weightInputToHidden[i][j]
            }
        }
        for (i in 0..=Int64(this.hiddenLayerSize - 1)) {
            for (j in 0..=Int64(this.outputLayerSize - 1)) {
                regLoss += weightHiddenToOutput[i][j] * weightHiddenToOutput[i][j]
            }
        }
        regLoss *= 0.5 * this.regularization / m

        return (totalLoss / m) + regLoss
    }

    // 批次反向传播（Adam优化器版本）
    func backwardBatch(batch: Matrix<Float32>, hiddenOutput: Matrix<Float32>, outputAfterActivation: Matrix<Float32>,
        labels: Matrix<Float32>) {
        let batchSize = batch.size
        let softmaxOutput = MatrixUtils.batchSoftmax(outputAfterActivation)

        // 第一步：计算误差
        // 输出层误差（m×10）：softmax输出 - 标签
        let numChunks = batchSize / chunkSize
        let outputLayerError = Matrix<Float32>(Int64(batchSize), item: Array<Float32>())

        AsyncTask(numChunks) {
            chunkIndex => spawn {
                for (i in chunkIndex * chunkSize..min((chunkIndex + 1) * chunkSize, batchSize)) {
                    let errRow = Array<Float32>(Int64(outputLayerSize), item: 0.0)
                    for (j in 0..=Int64(outputLayerSize - 1)) {
                        errRow[j] = softmaxOutput[i][j] - labels[i][j]
                    }
                    outputLayerError[i] = errRow
                }
            }
        }

        // 隐藏层误差（m×500）：输出层误差 × 隐藏→输出权重^T ⊙ ReLU导数
        let hiddenLayerError = Matrix<Float32>(Int64(batchSize), item: Array<Float32>())
        AsyncTask(numChunks) {
            chunkIndex => spawn {
                for (i in chunkIndex * chunkSize..min((chunkIndex + 1) * chunkSize, batchSize)) {
                    let errRow = Array<Float32>(Int64(hiddenLayerSize), item: 0.0)
                    for (j in 0..=Int64(hiddenLayerSize - 1)) {
                        for (k in 0..=Int64(outputLayerSize - 1)) {
                            errRow[j] += outputLayerError[i][k] * weightHiddenToOutput[j][k]
                        }
                        // ReLU导数
                        errRow[j] *= if (hiddenOutput[i][j] > 0.0) {
                            1.0
                        } else {
                            0.0
                        }
                    }
                    hiddenLayerError[Int64(i)] = errRow
                }
            }
        }

        // 第二步：准备Adam更新所需变量
        let batchSizeFloat = Float32(batchSize)
        let regularizationFactor = this.regularization
        optimizer.adamIteration += 1.0 // 迭代次数递增

        // 第三步：更新隐藏→输出权重（weightHiddenToOutput）
        AsyncTask(Int64(hiddenLayerSize) / chunkSize) {
            chunkIndex => spawn {
                for (iIndex in chunkIndex * chunkSize..min((chunkIndex + 1) * chunkSize, Int64(hiddenLayerSize))) {
                    for (jIndex in 0..Int64(outputLayerSize - 1)) {
                        var gradient: Float32 = 0.0
                        for (k in 0..batchSize - 1) {
                            gradient += hiddenOutput[k][iIndex] * outputLayerError[k][jIndex]
                        }
                        gradient = (gradient / batchSizeFloat) + (regularizationFactor * weightHiddenToOutput[iIndex][jIndex])

                        var (mHat, vHat) = optimizer.updateWeightHiddenToOutput(gradient, iIndex, jIndex)

                        // Adam参数更新
                        weightHiddenToOutput[iIndex][jIndex] -= (learningRate / (sqrt(vHat) + optimizer.adamEpsilon)) *
                            mHat
                    }
                }
            }
        }

        // 第四步：更新输出层偏置（biasOutputLayer）
        for (jIndex in 0..=Int64(outputLayerSize - 1)) {
            // 计算当前梯度（偏置无正则项）
            var gradient = Float32(0.0)
            for (k in 0..=Int64(batchSize - 1)) {
                gradient += outputLayerError[k][jIndex]
            }
            gradient /= batchSizeFloat
            // Adam动量更新
            var (mHat, vHat) = optimizer.updateBiaOutputLayer(gradient, jIndex)
            // Adam参数更新
            biasOutputLayer[jIndex] -= (learningRate / (sqrt(vHat) + optimizer.adamEpsilon)) * mHat
        }

        // 第五步：更新输入→隐藏权重（weightInputToHidden）=> 这一步是瓶颈 这里加了并发提升最大
        AsyncTask(Int64(inputLayerSize) / chunkSize) {
            chunkIndex => spawn {
                for (iIndex in chunkIndex * chunkSize..min((chunkIndex + 1) * chunkSize, Int64(inputLayerSize))) {
                    for (jIndex in 0..Int64(hiddenLayerSize - 1)) {
                        // 计算当前梯度（平均梯度 + L2正则项）
                        var gradient = Float32(0.0)
                        for (k in 0..=batchSize - 1) {
                            gradient += batch[k][iIndex] * hiddenLayerError[k][jIndex]
                        }
                        gradient = (gradient / batchSizeFloat) + (regularizationFactor * weightInputToHidden[iIndex][jIndex])
                        var (mHat, vHat) = optimizer.updateWeightInputToHidden(gradient, iIndex, jIndex)
                        // Adam参数更新
                        weightInputToHidden[iIndex][jIndex] -= (learningRate / (sqrt(vHat) + optimizer.adamEpsilon)) *
                            mHat
                    }
                }
            }
        }

        // 第六步：更新隐藏层偏置（biasHiddenLayer）
        for (jIndex in 0..=Int64(hiddenLayerSize - 1)) {
            // 计算当前梯度（偏置无正则项）
            var gradient = Float32(0.0)
            for (k in 0..=batchSize - 1) {
                gradient += hiddenLayerError[k][jIndex]
            }
            gradient /= batchSizeFloat
            var (mHat, vHat) = optimizer.updateBiasHiddenLayer(gradient, jIndex)
            // Adam参数更新
            biasHiddenLayer[jIndex] -= (learningRate / (sqrt(vHat) + optimizer.adamEpsilon)) * mHat
        }
    }

    // 单样本预测（返回类别索引）
    func predict(input: Array<Float32>): Int32 {
        // 前向传播（单样本）
        let hiddenPre = MatrixUtils.vecMatMul(input, this.weightInputToHidden)
        let hiddenAct = MatrixUtils.vecAdd(hiddenPre, this.biasHiddenLayer)
        let hiddenOut = MatrixUtils.relu(hiddenAct)

        let outputPre = MatrixUtils.vecMatMul(hiddenOut, this.weightHiddenToOutput)
        let outputAct = MatrixUtils.vecAdd(outputPre, this.biasOutputLayer)
        let softmaxOut = MatrixUtils.softmax(outputAct)

        // 找最大概率索引
        var maxProb = softmaxOut[0]
        var maxIndex: Int32 = 0
        for (idx in 1..=Int64(outputLayerSize - 1)) {
            if (softmaxOut[idx] > maxProb) {
                maxProb = softmaxOut[idx]
                maxIndex = Int32(idx)
            }
        }
        return maxIndex
    }
}
