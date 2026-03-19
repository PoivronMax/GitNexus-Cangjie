/**
 * Created on
 *      2025/9/17
 *      2025/9/4
 *      2025/8/29
 * ----------------
 * package MiniST
 *      module AsyncTask
 */

package MiniST

import std.ast.*

public func AsyncTask(n: Int64, lam: (Int64) -> Future<Unit>) {
    for (future in Array<Future<Unit>>(n, lam)) {
        future.get()
    }
}