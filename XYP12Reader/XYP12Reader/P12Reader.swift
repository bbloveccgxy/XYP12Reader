//
//  P12Reader.swift
//  XYP12Reader
//
//  Created by 高昕源 on 2018/4/24.
//  Copyright © 2018年 高昕源. All rights reserved.
//

import Foundation

public class P12Reader {
    let path : String
    let password : String
    let cmdSecurity : String = "/usr/bin/security"
    let keychain : String = "XYP12Reader.keychain"
    
    public var codesignIdentity : String = ""
    public var sha1 : String = ""
    
    public init(path: String, password: String) {
        self.path = path
        self.password = password
    }
    
    public func description() {
        print("Codesign Identity: \(self.codesignIdentity)")
        print("Sha1 hash: \(self.sha1)")
    }
    
    public func getInfo() {
        // 创建钥匙链
        self.create()
        
        // 解锁
        self.unlock()
        
        // 导入
        self.importKeychain()
        
        // 获取 codesignIdentity
        self.logCodesignIdentity()
        
        // 删除
        self.delete()
    }
    
    func create() {
        let argsCreate = ["create-keychain", "-p", self.password, self.keychain]
        let processCreate = Process()
        processCreate.launchPath = self.cmdSecurity
        processCreate.arguments = argsCreate
        processCreate.launch()
        processCreate.waitUntilExit()
    }
    
    func unlock() {
        let argsUnlock = ["unlock-keychain", "-p", self.password, self.keychain]
        let processUnlock = Process()
        processUnlock.launchPath = self.cmdSecurity
        processUnlock.arguments = argsUnlock
        processUnlock.launch()
        processUnlock.waitUntilExit()
    }
    
    func importKeychain() {
        let argsImport = ["import", self.path, "-k", self.keychain, "-P", self.password, "-T", "/usr/bin/codesign"]
        let processImport = Process()
        let outpipe = Pipe()
        let errpipe = Pipe()
        processImport.standardOutput = outpipe
        processImport.standardError = errpipe
        processImport.launchPath = self.cmdSecurity
        processImport.arguments = argsImport
        processImport.launch()
        processImport.waitUntilExit()
        
//        let outdata = outpipe.fileHandleForReading.availableData
        let errdata = errpipe.fileHandleForReading.availableData
        if errdata.count != 0  {
            //            let errString = String(data: errdata, encoding: String.Encoding.utf8) ?? ""
            self.delete()
            // 密码输错返回 1
            if processImport.terminationStatus == 1 {
                print("Wrong P12 Password")
            }
        }
    }
    
    func logCodesignIdentity() {
        let argsGet = ["find-certificate", "-Z", self.keychain]
        let processGet = Process()
        let outpipeGet = Pipe()
        let errpipeGet = Pipe()
        processGet.standardOutput = outpipeGet
        processGet.standardError = errpipeGet
        processGet.launchPath = cmdSecurity
        processGet.arguments = argsGet
        processGet.launch()
        processGet.waitUntilExit()
        
        let outdataGet = outpipeGet.fileHandleForReading.availableData
        let errdataGet = errpipeGet.fileHandleForReading.availableData
        if errdataGet.count != 0  {
            let errString = String(data: errdataGet, encoding: String.Encoding.utf8) ?? ""
            print(errString)
        }
        
        let stringGet = String(data: outdataGet, encoding: String.Encoding.utf8) ?? ""
        let strArr = stringGet.components(separatedBy: "\n")
        
        let sha1Hash = strArr[0]
        self.sha1 = sha1Hash.replacingOccurrences(of: "SHA-1 hash: ", with: "")
        
        let str = strArr[5]
        let startIndex = str.index(str.startIndex, offsetBy: 18)
        let endIndex = str.index(str.endIndex, offsetBy: -1)
        // codesignIdentity
        let stdout = String(str[startIndex..<endIndex])
        self.codesignIdentity = stdout
    }
    
    func delete() {
        let argsDelete = ["delete-keychain", self.keychain]
        let processDelete = Process()
        processDelete.launchPath = self.cmdSecurity
        processDelete.arguments = argsDelete
        processDelete.launch()
        processDelete.waitUntilExit()
    }
}
