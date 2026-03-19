/**
 * Created on
 *      2025/9/17
 *      2025/9/4
 *      2025/8/29
 * ----------------
 * package MiniST
 *      module Trainer
 */

package MiniST

import std.random.*
import std.time.*
import std.sync.*
import std.math.*

// 4. 优化的训练器（批次处理）
class Trainer {
    private let chunkSize = BPNetwork.chunkSize
    public Trainer(
        private let network: BPNetwork,
        private let batchSize: Int32,
        private let epochs: Int32
    ) {}

    // 引用传递的Shuffle（Fisher-Yates）
    static func shuffleArray(arr: Array<Int64>) {
        let len = arr.size
        let random = Random()
        for (i in 0..=len - 1) {
            let j = Int64(random.nextUInt64(UInt64(len - i))) + i
            let temp = arr[i]
            arr[i] = arr[j]
            arr[j] = temp
        }
    }

    // 拆分训练集和验证集
    static func trainValSplit(images: Matrix<Float32>, labels: Matrix<Float32>, valRatio: Float32): (Matrix<Float32>, 
        Matrix<Float32>, Matrix<Float32>, Matrix<Float32>) {
        let total = images.size
        let valSize = Int64(Float32(total) * valRatio)
        let trainSize = total - valSize

        // 打乱索引
        var indices = Array<Int64>(Int64(total), item: 0)
        for (i in 0..=total - 1) {
            indices[Int64(i)] = Int64(i)
        }
        shuffleArray(indices)

        // 拆分数据
        let trainImages = Matrix<Float32>(trainSize, item: Array<Float32>())
        let trainLabels = Matrix<Float32>(trainSize, item: Array<Float32>())
        let valImages = Matrix<Float32>(valSize, item: Array<Float32>())
        let valLabels = Matrix<Float32>(valSize, item: Array<Float32>())

        for (i in 0..=trainSize - 1) {
            trainImages[i] = images[indices[i]]
            trainLabels[i] = labels[indices[i]]
        }
        for (i in 0..=valSize - 1) {
            valImages[i] = images[indices[trainSize + i]]
            valLabels[i] = labels[indices[trainSize + i]]
        }
        return (trainImages, trainLabels, valImages, valLabels)
    }

    // 计算准确率
    func accuracy(images: Matrix<Float32>, labels: Matrix<Float32>): Float32 {
        let total = images.size
        let correct = AtomicInt32(0)

        let numChunks = total / chunkSize
        let futs: Array<?Future<Unit>> = Array(numChunks, item: None)
        for (chunkIndex in 0..numChunks) {
            futs[chunkIndex] = spawn {
                for (i in chunkIndex * chunkSize..min(chunkIndex * chunkSize + chunkSize, total)) {
                    let pred = network.predict(images[Int64(i)])
                    // 找真实标签索引
                    let labelRow = labels[Int64(i)]
                    for (j in 0..=9) {
                        if (labelRow[Int64(j)] == 1.0) {
                            if (Int64(pred) == j) {
                                correct.fetchAdd(1)
                            }
                            break
                        }
                    }
                }
            }
        }

        for (f in futs) {
            f.getOrThrow().get()
        }
        return Float32(correct.load()) / Float32(total)
    }

    // 批次训练主循环
    func train(trainImages: Matrix<Float32>, trainLabels: Matrix<Float32>, valImages: Matrix<Float32>,
        valLabels: Matrix<Float32>) {
        let total = trainImages.size
        let batchesPerEpoch = (Int32(total) + batchSize - 1) / batchSize // 向上取整

        for (epoch in 0..=epochs - 1) {
            // 打乱训练数据
            var indices = Array<Int64>(Int64(total), item: 0)
            for (i in 0..=total - 1) {
                indices[Int64(i)] = Int64(i)
            }
            Trainer.shuffleArray(indices)

            var totalLoss = Float32(0.0)

            var startTime = MonoTime.now()
            // 批次训练
            for (batch in 0..=batchesPerEpoch - 1) {
                let start = Int64(batch * batchSize)
                var end = start + Int64(batchSize)
                if (end > total) {
                    end = total
                }
                let batchSizeActual = end - start

                // 提取当前批次数据
                let batchImages = Matrix<Float32>(batchSizeActual, item: Array<Float32>())
                let batchLabels = Matrix<Float32>(batchSizeActual, item: Array<Float32>())
                for (i in 0..=batchSizeActual - 1) {
                    let idx = indices[start + i]
                    batchImages[i] = trainImages[idx]
                    batchLabels[i] = trainLabels[idx]
                }

                // 前向传播+计算损失
                let (hiddenOut, output) = network.forwardBatch(batchImages)
                let batchLoss = network.computeBatchLoss(output, batchLabels)
                totalLoss += batchLoss * Float32(batchSizeActual)

                // 反向传播更新参数
                network.backwardBatch(batchImages, hiddenOut, output, batchLabels)

                // 每100批次打印进度（减少IO）

                let avgLoss = totalLoss / Float32(start + batchSizeActual)
                let endTime = MonoTime.now()
                if ((batch + 1) % 10 == 0) {
                    println(
                        "Epoch ${epoch+1/epochs}, Batch ${batch}/${batchesPerEpoch}, 平均损失: ${avgLoss}, 耗时：${endTime - startTime}, 验证集准确率: ${accuracy(valImages, valLabels)}"
                    )
                } else {
                    println(
                        "Epoch ${epoch+1/epochs}, Batch ${batch}/${batchesPerEpoch}, 平均损失: ${avgLoss}, 耗时：${endTime - startTime}"
                    )
                }
                startTime = endTime
            }

            // 每个Epoch评估验证集
            let valAcc = accuracy(valImages, valLabels)
            println("Epoch ${epoch+1} 完成，验证集准确率: ${valAcc}")
        }
    }
}
