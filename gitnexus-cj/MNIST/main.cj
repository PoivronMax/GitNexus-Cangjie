/**
 * Created on 
 *      2025/9/17
 *      2025/9/4 
 *      2025/8/29
 * ----------------
 * package MiniST
 *      main
 */ 

package MiniST

/**
 * 优化说明：
 * 1. 批次级向量化运算（替代单样本循环）
 * 2. 修复数值稳定性问题（Softmax排序、权重初始化）
 * 3. 优化矩阵运算循环顺序（利用缓存局部性）
 * 4. 减少不必要的内存分配和打印操作
 */
public type Matrix<T> = Array<Array<T>>

// 主函数入口
main() {
    println("优化版纯仓颉手写数字识别启动...")

    // 配置参数
    let INPUT_SIZE: Int32 = 784
    let HIDDEN_SIZE: Int32 = 500
    let OUTPUT_SIZE: Int32 = 10
    let LEARNING_RATE: Float32 = 0.005
    let REGULARIZATION: Float32 = 0.01
    let BATCH_SIZE: Int32 = 200
    let EPOCHS: Int32 = 1

    // 1. 加载数据（请替换为实际路径）
    let trainLoader = MiniSTLoader(
        "./dataset/train-images-idx3-ubyte",
        "./dataset/train-labels-idx1-ubyte"
    )
    let (trainImages, trainLabels) = trainLoader.loadData()
    println("训练数据加载完成: ${trainImages.size} 样本")

    let testLoader = MiniSTLoader(
        "./dataset/t10k-images-idx3-ubyte",
        "./dataset/t10k-labels-idx1-ubyte"
    )
    let (testImages, testLabels) = testLoader.loadData()
    println("测试数据加载完成: ${testImages.size} 样本")

    // 2. 拆分训练集和验证集（10%验证集）
    let (trainImgs, trainLbls, valImgs, valLbles) = Trainer.trainValSplit(trainImages, trainLabels, 0.1)
    println("数据拆分完成: 训练集${trainImgs.size}, 验证集${(valImgs.size)}")

    // 3. 初始化网络和训练器
    let network = BPNetwork(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, LEARNING_RATE, REGULARIZATION)
    let trainer = Trainer(network, BATCH_SIZE, EPOCHS)

    // 4. 启动训练
    println("开始训练...")
    trainer.train(trainImgs, trainLbls, valImgs, valLbles)

    // 5. 测试集评估
    let testAcc = trainer.accuracy(testImages, testLabels)
    println("训练完成，测试集准确率: ${testAcc}")
}
