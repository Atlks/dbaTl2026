

vs more good...


laucnh.json
4. "runtimeArgs": ["-r", "ts-node/register"]
   关键点在这里：

让 Node 在启动时加载 ts-node/register

这样 Node 就能直接执行 .ts 文件

不需要


idea cant ..catn dbg



但有两个前提
你的项目必须安装：

Code
npm install ts-node typescript --save-dev
你的 TypeScript 需要 sourcemap 支持（否则断点可能偏移）：

tsconfig.json 里要有：

json
{
"compilerOptions": {
"sourceMap": true
}
}




prj   godbscrfpt
incde..lauch.json and tsconfig.json



🧩 配置的作用说明
1. "type": "node"
   告诉 VS Code 用 Node.js  调试器。

2. "request": "launch"
   表示启动一个新的 Node 进程，而不是附加到已有进程。

3. "args": ["${relativeFile}"]
   表示运行你当前打开的文件，非常适合“单点调试”。

4. "runtimeArgs": ["-r", "ts-node/register"]
   关键点在这里：

让 Node 在启动时加载 ts-node/register

这样 Node 就能直接执行 .ts 文件

不需要 tsc 编译

5. "cwd": "${workspaceRoot}"
   设置工作目录为项目根目录。

6. "protocol": "inspector"
   使用 Node 的 inspector 协议（现代调试方式）。

🎯 结论：适合单点调试吗？
✔️ 适合
你想直接运行某个 .ts 文件

你想在 VS Code 里打断点

你使用 ts-node

你不需要先编译


