/**
 * Created on
 *      2025/9/17
 *      2025/9/4
 *      2025/8/29
 * ----------------
 * package MiniST
 *      module MiniSTLoader
 */

package MiniST

import std.fs.*

// 1. 数据加载类（保持高效解析）
class MiniSTLoader {
    var imagePath: String = ""
    var labelPath: String = ""

    public init(imgPath: String, labelPath: String) {
        this.imagePath = imgPath
        this.labelPath = labelPath
    }

    // 解析大端格式32位整数
    public func unpackI32(buffer: Array<UInt8>, offset: Int32): Int32 {
        return (Int32(buffer[Int64(offset)])) << 24 | (Int32(buffer[Int64(offset + 1)])) << 16 |
            (Int32(buffer[Int64(offset + 2)])) << 8 | (Int32(buffer[Int64(offset + 3)]))
    }

    // 加载图像数据（归一化到0-1）
    func loadImages(): Matrix<Float32> {
        let file = File(this.imagePath, OpenOption.Open(true, false)) // 只读模式
        let buffers = file.readToEnd()
        file.close()

        let imgNum = unpackI32(buffers, 4)
        let width = unpackI32(buffers, 8)
        let height = unpackI32(buffers, 12)
        let pixelCount = Int64(width * height)

        // 预分配内存避免动态扩容
        let images = Matrix<Float32>(Int64(imgNum), item: Array<Float32>())
        for (i in 0..=Int64(imgNum - 1)) {
            let row = Array<Float32>(Int64(pixelCount), item: 0.0)
            let baseIdx = 16 + i * pixelCount
            for (j in 0..=Int64(pixelCount - 1)) {
                row[j] = Float32(buffers[baseIdx + j]) / 255.0
            }
            images[Int64(i)] = row
        }
        return images
    }

    // 加载标签数据（转为one-hot编码）
    func loadLabels(): Matrix<Float32> {
        let file = File(this.labelPath, OpenOption.Open(true, false)) // 只读模式
        let buffers = file.readToEnd()
        file.close()

        let labelNum = unpackI32(buffers, 4)

        // 预分配内存
        let labels = Matrix<Float32>(Int64(labelNum)) {
            i => Array<Float32>(10) {
                j => if (j == Int64(buffers[8 + i])) {
                    1.0
                } else {
                    0.0
                }
            }
        }
        return labels
    }

    // 加载完整数据集
    func loadData(): (Matrix<Float32>, Matrix<Float32>) {
        let images = this.loadImages()
        let labels = this.loadLabels()
        return (images, labels)
    }
}
