/**
 * Created on
 *      2025/9/17
 *      2025/9/4
 *      2025/8/29
 * ----------------
 * package MiniST
 *      module MatrixUtils
 */

package MiniST

import std.math.*
import std.runtime.*
import std.random.*

// 2. 优化的矩阵工具类（批次级向量化运算）
class MatrixUtils {
    public static let chunkSize: Int64 = BPNetwork.chunkSize
    // 批次向量×矩阵（batch: m×n, mat: n×p → result: m×p）
    public static func batchVecMatMul(batch: Matrix<Float32>, mat: Matrix<Float32>): Matrix<Float32> {
        let m = batch.size
        let n = mat.size
        let p = mat[0].size
        let result = Matrix<Float32>(Int64(m)) {i => Array<Float32>(Int64(p), item: 0.0)}

        AsyncTask(n / chunkSize) {
            s => spawn {
                for (k in s * chunkSize..min(s * chunkSize + chunkSize, n)) {
                    let kIndex = Int64(k)
                    for (iIndex in 0..=m - 1) {
                        let val = batch[iIndex][kIndex]
                        if (val == 0.0) {
                            continue
                        } // 稀疏优化
                        for (jIndex in 0..=p - 1) {
                            result[iIndex][jIndex] += val * mat[kIndex][jIndex]
                        }
                    }
                }
            }
        }
        return result
    }

    // 批次矩阵+偏置（广播）
    public static func batchAddBias(batch: Matrix<Float32>, bias: Array<Float32>): Matrix<Float32> {
        let m = batch.size
        let n = batch[0].size
        let result = Matrix<Float32>(Int64(m), item: Array<Float32>())

        AsyncTask((m + chunkSize - 1) / chunkSize) {
            chunkIndex =>
            let start = chunkIndex * chunkSize
            let end = min(start + chunkSize, m)
            spawn {
                for (iIndex in start..end) {
                    let row = Array<Float32>(n, item: 0.0)
                    for (j in 0..=n - 1) {
                        row[j] = batch[iIndex][j] + bias[j]
                    }
                    result[iIndex] = row
                }
            }
        }
        return result
    }

    // 批次ReLU激活
    public static func batchRelu(batch: Matrix<Float32>): Matrix<Float32> {
        let m = batch.size
        let n = batch[0].size
        let result = Matrix<Float32>(Int64(m), item: Array<Float32>())

        AsyncTask((m + chunkSize - 1) / chunkSize) {
            s =>
            let start = s * chunkSize
            let end = min(start + chunkSize, m)
            spawn {
                for (iIndex in start..end) {
                    let row = Array<Float32>(n, item: 0.0)
                    for (j in 0..=n - 1) {
                        let val = batch[iIndex][j]
                        row[j] = if (val > 0.0) {
                            val
                        } else {
                            0.0
                        }
                    }
                    result[iIndex] = row
                }
            }
        }
        return result
    }

    // 批次Softmax（数值稳定版）
    public static func batchSoftmax(batch: Matrix<Float32>): Matrix<Float32> {
        let m = batch.size
        let n = batch[0].size
        let result = Matrix<Float32>(Int64(m), item: Array<Float32>())

        AsyncTask((m + chunkSize - 1) / chunkSize) {
            s =>
            let start = s * chunkSize
            let end = min(start + chunkSize, m)
            spawn {
                for (iIndex in start..end) {
                    let row = batch[iIndex]
                    // 找每行最大值（数值稳定）
                    var maxVal = row[0]
                    for (j in 1..=n - 1) {
                        if (row[j] > maxVal) {
                            maxVal = row[j]
                        }
                    }

                    // 计算指数和
                    var expSum = Float32(0.0)
                    let expVals = Array<Float32>(n, item: 0.0)
                    for (j in 0..=n - 1) {
                        expVals[j] = exp(row[j] - maxVal)
                        expSum += expVals[j]
                    }

                    // 归一化
                    let softmaxRow = Array<Float32>(Int64(n), item: 0.0)
                    for (j in 0..=n - 1) {
                        softmaxRow[j] = expVals[j] / expSum
                    }
                    result[iIndex] = softmaxRow
                }
            }
        }
        return result
    }

    // 向量×矩阵（单样本辅助函数）
    public static func vecMatMul(vec: Array<Float32>, mat: Matrix<Float32>): Array<Float32> {
        let n = vec.size
        let p = mat[0].size
        let result = Array<Float32>(Int64(p), item: 0.0)

        for (kIndex in 0..=n - 1) {
            let val = vec[kIndex]
            if (val == 0.0) {
                continue
            }
            for (j in 0..=p - 1) {
                result[j] += val * mat[kIndex][j]
            }
        }
        return result
    }

    // 向量+偏置（单样本辅助函数）
    public static func vecAdd(vec: Array<Float32>, bias: Array<Float32>): Array<Float32> {
        let n = vec.size
        let result = Array<Float32>(Int64(n), item: 0.0)
        for (i in 0..=n - 1) {
            result[i] = vec[i] + bias[i]
        }
        return result
    }

    // 单样本ReLU（辅助函数）
    public static func relu(vec: Array<Float32>): Array<Float32> {
        let n = vec.size
        let result = Array<Float32>(Int64(n), item: 0.0)
        for (i in 0..=n - 1) {
            let val = vec[i]
            result[i] = if (val > 0.0) {
                val
            } else {
                0.0
            }
        }
        return result
    }

    // 单样本Softmax（辅助函数）
    public static func softmax(vec: Array<Float32>): Array<Float32> {
        let n = vec.size
        var maxVal = vec[0]
        for (i in 1..=n - 1) {
            if (vec[i] > maxVal) {
                maxVal = vec[i]
            }
        }

        var expSum = Float32(0.0)
        let expVals = Array<Float32>(n, item: 0.0)
        for (i in 0..=n - 1) {
            expVals[i] = exp(vec[i] - maxVal)
            expSum += expVals[i]
        }

        let result = Array<Float32>(n, item: 0.0)
        for (i in 0..=n - 1) {
            result[i] = expVals[i] / expSum
        }
        return result
    }

    public static func randomInit(row: Int32, col: Int32): Matrix<Float32> {
        let result = Matrix<Float32>(Int64(row), item: Array<Float32>())
        let stddev = sqrt(2.0 / (Float32(row) + Float32(col))) // 正确的sigma
        let r = Random()

        for (i in 0..=Int64(row - 1)) {
            let rowArr = Array<Float32>(Int64(col), item: 0.0)
            for (j in 0..=Int64(col - 1)) {
                // 正确的正态分布参数
                var val = r.nextGaussianFloat32(mean: 0.0, sigma: stddev)
                // 截断到[-2σ, 2σ]
                if (val < -2.0 * stddev) {
                    val = -2.0 * stddev
                }
                if (val > 2.0 * stddev) {
                    val = 2.0 * stddev
                }
                rowArr[j] = val
            }
            result[i] = rowArr
        }
        return result
    }
}
