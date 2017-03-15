//
//  main.swift
//  clusters
//
//  Created by Istros Anlagen on 30/12/2016.
//  Copyright © 2016 ___Istros Anlagen sro___. All rights reserved.
//

import Foundation


func base (add : String)->(NSArray) {
    let nadd = (add as NSString).stringByExpandingTildeInPath
    let dat = NSArray(contentsOfFile:nadd)
    return dat!
}
var minInputs = Array<Float>()
var maxInputs = Array<Float>()
var maxminInputs = Array<Float>()

let nv : Int = 7
let add = "~/Finance/Aetius/exportPopLarge.plist"
let ibase : NSArray = base(add)


func setMinMax(base : NSArray) {
    var pat = Array<Array<Float>>()
    for item in base {
        let item2  = item as! NSDictionary
        let pbr = item2.objectForKey("etafiNY.pbr") as! Float
        let roe : Float = item2.objectForKey("etafiNY.roe") as! Float
        //      let gearing : Double = item2.objectForKey("etafiNY.gearing") as! Double
        let levScore2 = item2.objectForKey("levScore2") as! Float
        let trc4 = item2.objectForKey("trc4") as! Float
        let potg = item2.objectForKey("etafiNY.potg") as! Float
        let varroce : Float = item2.objectForKey("etafiVar.roce") as! Float
        let tvarroce : Float = truncsigm (varroce, coef: 25.0)
        let implGeva : Float = item2.objectForKey("etafiNY.implGeva") as! Float
        let timplGeva : Float = truncsigm (implGeva, coef: 10.0)
        let iar : Array<Float> = [pbr, roe, potg, levScore2, trc4, tvarroce, timplGeva]
        pat.append(iar)
    }
    
    for p in 0...pat.count-1{
        var inputs = pat[p]
        if p == 0 {
            maxInputs = pat[p]
            minInputs = pat[p]
        }
        for j in 0...inputs.count-1 {
            if inputs[j] > maxInputs[j] {
                maxInputs[j] = inputs[j]
            } else
                if inputs[j] < minInputs[j] {
                    minInputs[j] = inputs[j]
            }
        }
    }
    let ni = pat[0].count
    maxminInputs = [Float](count: ni, repeatedValue:0.0)
    for j in 0...ni-1 {
        maxminInputs[j] = maxInputs[j] - minInputs[j]
    }
}

func filteredBase (secteur : String)->(NSArray) {
    let pred : NSPredicate = NSPredicate.init(format:"secteur BEGINSWITH[cd] %@", argumentArray:[secteur])
    let fb = ibase.filteredArrayUsingPredicate(pred)
    return fb
}

func cafilteredBase (casecteurs : [String])->(NSArray) {
    var arpred : Array<NSPredicate> = Array()
    for index in casecteurs.indices {
        let predi : NSPredicate = NSPredicate.init(format:"secteur BEGINSWITH[cd] %@", argumentArray:[casecteurs[index]])
        arpred.append(predi)
    }
    let superPred = NSCompoundPredicate.init(orPredicateWithSubpredicates : arpred)
    let fb = ibase.filteredArrayUsingPredicate(superPred)
    return fb
}

func barycentre (base : NSArray)->(Array<Float>) {
    let pat : Array<Array<Float>> = chargeData2(base)
    let n = pat.count
    var psi = [Float](count: nv, repeatedValue:0.0)
    for i in 0..<nv {
        var ssi : Float = 0.0
        for fi : Array<Float> in pat {
            ssi += fi[i]
            psi[i] = ssi / Float(n)
        }
    }
    return psi
}

func barycentre (pat : Array<Array<Float>>)->(Array<Float>) {
//    let pat : Array<Array<Float>> = chargeData2(base)
    let n = pat.count
    var psi = [Float](count: nv, repeatedValue:0.0)
    for i in 0..<nv {
        var ssi : Float = 0.0
        for fi : Array<Float> in pat {
            ssi += fi[i]
            psi[i] = ssi / Float(n)
        }
    }
    return psi
}

func barycentre (secteur : String)->([Float]) {
    let cb = filteredBase(secteur)
    return barycentre(cb)
}

func barycentre (casecteurs : [String])->([Float]) {
    let cb = cafilteredBase(casecteurs)
    return barycentre(cb)
}

func truncsigm(x:Float, coef:Float)->Float {
    if coef > 0.0 {
        return coef * tanh(x/coef)
    } else {
        return 0.0
    }
}

func chargeData(add : String)->(Array<Array<Float>>) {
    let nadd = (add as NSString).stringByExpandingTildeInPath
    let dat = NSArray(contentsOfFile:nadd)
    var pat = Array<Array<Float>>()
    
    for item in dat! {
        let item2  = item as! NSDictionary
        let pbr = item2.objectForKey("etafiNY.pbr") as! Float
        let roe : Float = item2.objectForKey("etafiNY.roe") as! Float
   //     let gearing : Float = item2.objectForKey("etafiNY.gearing") as! Float
        let levScore2 = item2.objectForKey("levScore2") as! Float
        let trc4 = item2.objectForKey("trc4") as! Float
        let potg = item2.objectForKey("etafiNY.potg") as! Float
        let varroce : Float = item2.objectForKey("etafiVar.roce") as! Float
        let tvarroce : Float = truncsigm (varroce, coef: 25.0)
        let implGeva : Float = item2.objectForKey("etafiNY.implGeva") as! Float
        let timplGeva : Float = truncsigm (implGeva, coef: 10.0)
        let iar : Array<Float> = [pbr, roe, potg, levScore2, trc4, tvarroce, timplGeva]
        pat.append(iar)
    }
    let pat2 = normalise(pat)
    return pat2
}

func chargeData2(base : NSArray)->(Array<Array<Float>>) {
    var pat = Array<Array<Float>>()
    for item in base {
        let item2  = item as! NSDictionary
        let pbr = item2.objectForKey("etafiNY.pbr") as! Float
        let roe : Float = item2.objectForKey("etafiNY.roe") as! Float
        //      let gearing : Double = item2.objectForKey("etafiNY.gearing") as! Double
        let levScore2 = item2.objectForKey("levScore2") as! Float
        let trc4 = item2.objectForKey("trc4") as! Float
        let potg = item2.objectForKey("etafiNY.potg") as! Float
        let varroce : Float = item2.objectForKey("etafiVar.roce") as! Float
        let tvarroce : Float = truncsigm (varroce, coef: 25.0)
        let implGeva : Float = item2.objectForKey("etafiNY.implGeva") as! Float
        let timplGeva : Float = truncsigm (implGeva, coef: 10.0)
        let iar : Array<Float> = [pbr, roe, potg, levScore2, trc4, tvarroce, timplGeva]
        pat.append(iar)
    }
    let pat2 = normalise(pat)
    return pat2
}

func normalise(patterns:Array<Array<Float>>)->(Array<Array<Float>>) {
   /*
    for p in 0...patterns.count-1{
        var inputs = patterns[p]
        if p == 0 {
            maxInputs = patterns[p]
            minInputs = patterns[p]
        }
        for j in 0...inputs.count-1 {
            if inputs[j] > maxInputs[j] {
                maxInputs[j] = inputs[j]
            } else
                if inputs[j] < minInputs[j] {
                    minInputs[j] = inputs[j]
            }
        }
    }
    let ni = patterns[0].count
    var maxminInputs = [Float](count: ni, repeatedValue:0.0)
    for j in 0...ni-1 {
        maxminInputs[j] = maxInputs[j] - minInputs[j]
    }
    */
    var npatterns = Array<Array<Float>>()
    
    for p in 0...patterns.count-1{
        var inputs = patterns[p]
        
        for j in 0...inputs.count-1 {
            inputs[j] =  (inputs[j] - minInputs[j]) / maxminInputs[j]
        }
        npatterns.append(inputs)
    }
    
    return npatterns
}

func dist(a: Array<Float>, b: Array<Float>)->(Float) {
    var ssi : Float = 0.0
    for (index, number) in a.enumerate() {
        let fbi = b[index]
        let si = (number - fbi) * (number - fbi)
        ssi += si
    }
    return sqrtf(ssi)
}

func distglobale(a: Array<Float>, aa : Array<Array<Float>>)->(Float) {
    let ac = aa.count
    if ac <= 1 {
        return 0.0
    } else {
        var ssi : Float = 0.0
        for item in aa {
            let d = dist(a, b: item)
            ssi += d
        }
        return ssi/Float(ac) // ?
    }
}

func di (secteur : String)->(Float) {
//    let baryi = barycentre(secteur)
    let cb = filteredBase(secteur)
    let pati = chargeData2(cb)
    let baryi = barycentre(pati)
    let di = distglobale(baryi, aa: pati)
    return di
}

func pop (secteur : String)->(Int) {
    let cb = filteredBase(secteur)
    let p = cb.count
    return p
}

func pop (casecteurs : [String])->(Int) {
    let cb = cafilteredBase(casecteurs)
    let p = cb.count
    return p
}

func di (casecteurs : [String])->(Float) {
    let baryi = barycentre(casecteurs)
    let cb = cafilteredBase(casecteurs)
    let pati = chargeData2(cb)
    let di = distglobale(baryi, aa: pati)
    return di
}

func rdi (secteur : String)->(Float) { // ratio entre la dist. moyenne du cluster / dist. moy de tous les points au barycentre du clister
    let baryi = barycentre(secteur)
    let cb = filteredBase(secteur)
    let pati = chargeData2(cb)
    let di = distglobale(baryi, aa: pati)
    let dig = distglobale(baryi, aa: pat)
    let rdi = di / dig
    return rdi
}

func rdi (casecteurs : [String])->(Float) {
    let baryi = barycentre(casecteurs)
    let cb = cafilteredBase(casecteurs)
    let pati = chargeData2(cb)
    let di = distglobale(baryi, aa: pati)
    let dig = distglobale(baryi, aa: pat)
    let rdi = di / dig
    return rdi
}

func maxDB (secteur : String, secteurs : [String])->(Float) {
    var max : Float = 0.0
    let baryi = barycentre(secteur)
    let dii = di(secteur)
    for jsect in secteurs {
        if jsect != secteur {
            let dij = di(jsect)
            let baryj = barycentre(jsect)
            let dbaryij = dist(baryi, b: baryj)
            if dbaryij != 0.0 {
                let ratij = ( dii + dij) / dbaryij
                if ratij > max {
                    max = ratij
                }
            }
        }
    }
    return max
}

func maxDB (casecteurs : [String], secteurs : [[String]])->(Float) {
    var max : Float = 0.0
    let baryi = barycentre(casecteurs)
    let dii = di(casecteurs)
    for jsect in secteurs {
        if jsect != casecteurs {
            let dij = di(jsect)
            let baryj = barycentre(jsect)
            let dbaryij = dist(baryi, b: baryj)
            if dbaryij != 0.0 {
                let ratij = ( dii + dij) / dbaryij
                if ratij > max {
                    max = ratij
                }
            }
        }
    }
    return max
}

func DBindex (secteurs : [String])->(Float) { // Davies–Bouldin index, the smallest the best !
    let n = secteurs.count
    var sum : Float = 0.0
    for isect in secteurs {
        sum += maxDB(isect, secteurs: secteurs)
    }
    return sum / Float(n)
}

func DBindex (casecteurs : [[String]])->(Float) { // Davies–Bouldin index, the smallest the best !
    let n = casecteurs.count
    var sum : Float = 0.0
    for isect in casecteurs {
        sum += maxDB(isect, secteurs: casecteurs)
    }
    return sum / Float(n)
}

var pat = Array<Array<Float>>()
setMinMax(ibase)
pat = chargeData(add)

let lni = pat[0].count
print(pat.count)

let liste : [String] = ["M.", "C.", "S.", "E.", "F.", "H.", "I.", "RE.", "TC.", "UT."]
//let liste : [String] = ["M.", "C.", "S.", "F.", "H.", "I.", "RE.", "TC.", "UT."]
/*
// let d01 : Float = dist(pat[0], b: pat[1])
// print(d01)
// let dg = distglobale(pat[0], aa: pat)
// print(dg)
let baryg = barycentre(ibase)
print("barycentre global : \(baryg)")
let cb = filteredBase("I")
print(cb.count)
let patI = chargeData2(cb)
// let dgI = distglobale(patI[0], aa: patI)
// print(dgI)
let baryI = barycentre(cb)
print(baryI)
let di = distglobale(baryI, aa: patI)
print("dist globale I :\(di)")
let dig = distglobale(baryI, aa: pat)
print("dist globale generale I :\(dig)")
let rdi = di / dig
print("ratio dist globale I :\(rdi)")

let lb = liste.map { barycentre($0)}
let lc = lb.map { distglobale($0, aa: lb)}
print(lb)
// print(lc)
for index in liste.indices {
    print("\(liste[index]) : \(lc[index])")
}
let lr = liste.map { rdi($0) }
for index in liste.indices {
    print("\(liste[index]) rdi : \(lr[index])")
}
let dbi = DBindex(liste)
print("Davies-Bouldin index : \(dbi)")

for index in liste.indices {
    let baryi = barycentre(liste[index])
    let ldi = lb.map { dist(baryi, b: $0)}
    print("\(liste[index]) : \(ldi)")
}
*/
let liste2 : [[String]] = [["M","RE","I","UT"],["C","S","H","I","TC"]]
/*
let lb2 = liste2.map { barycentre($0)}
let lc2 = lb2.map { distglobale($0, aa: lb2)}
print(lb2)
// print(lc)
for index in liste2.indices {
    print("\(liste2[index]) : \(lc2[index])")
}
let lr2 = liste2.map { rdi($0) }
for index in liste2.indices {
    print("\(liste2[index]) rdi : \(lr2[index])")
}
let dbi2 = DBindex(liste2)
print("Davies-Bouldin index : \(dbi2)")

for index in liste2.indices {
    let baryi = barycentre(liste2[index])
    let ldi = lb2.map { dist(baryi, b: $0)}
    print("\(liste2[index]) : \(ldi)")
}
*/
func detailcluster(liste : [String]) {
    print("DETAILS CLUSTER selon \(liste)")
    print("***")
    let lb = liste.map { barycentre($0)}
    let lc = lb.map { distglobale($0, aa: lb)}
    let lpop = liste.map { pop($0)}
    print(lb)
    for index in liste.indices {
        print("\(liste[index]) : \(lc[index]) - pop : \(lpop[index])")
    }
    let lr = liste.map { rdi($0) }
    for index in liste.indices {
        print("\(liste[index]) rdi : \(lr[index])")
    }
    let dbi = DBindex(liste)
    print("Davies-Bouldin index : \(dbi)")
    for index in liste.indices {
        let baryi = barycentre(liste[index])
        let ldi = lb.map { dist(baryi, b: $0)}
        print("\(liste[index]) : \(ldi)")
    }
    print("***********")
}

func detailcluster(liste : [[String]]) {
    print("DETAILS CLUSTER selon \(liste)")
    print("***")
    let lb = liste.map { barycentre($0)}
    let lc = lb.map { distglobale($0, aa: lb)}
    let lpop = liste.map { pop($0)}
    print(lb)
    for index in liste.indices {
        print("\(liste[index]) : \(lc[index]) - pop : \(lpop[index])")
    }
    let lr = liste.map { rdi($0) }
    for index in liste.indices {
        print("\(liste[index]) rdi : \(lr[index])")
    }
    let dbi = DBindex(liste)
    print("Davies-Bouldin index : \(dbi)")
    for index in liste.indices {
        let baryi = barycentre(liste[index])
        let ldi = lb.map { dist(baryi, b: $0)}
        print("\(liste[index]) : \(ldi)")
    }
    print("***********")
}
let liste3 : [[String]] = [["M","RE","UT"],["C","S","F","H"],["I"],["TC"]]  // nul
let liste4 : [[String]] = [["M","UT","H", "E"],["C","S"],["I"],["F","TC","RE"]]  // *** DBidx 8,9
let liste5 : [[String]] = [["M","H","E"],["TC","UT","F"],["C","S"],["I","RE"]]
let liste6 : [[String]] = [["M","H","E"],["TC","UT","F"],["C"],["S"],["RE"],["I"]] // *** DBidx 7,8
detailcluster(liste)
detailcluster(liste2)
detailcluster(liste3)
detailcluster(liste4)
detailcluster(liste5)
detailcluster(liste6)