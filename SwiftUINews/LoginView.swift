//
//  LoginView.swift
//  SwiftUINews
//
//  Created by Hoo on 2021/6/3.
//

import SwiftUI
import CoreData
let LightGreyColor = Color(red:239.0 / 255.0,green:243.0 / 255.0,blue:244.0 / 255.0)
var initname = false
var getNamesFetchRequest: NSFetchRequest<UserDefaults> {
    let request: NSFetchRequest<UserDefaults> = UserDefaults.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    return request
}

struct LoginView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: getNamesFetchRequest)
    var names: FetchedResults<UserDefaults>
    @Binding var needLogin: Bool
    @State var username : String = ""
    @State var password : String = ""
    @State var authenticationDidFail :Bool = false
//    init(needLogin: Binding<Bool>) {
//        self._needLogin = needLogin
//        let data = names.map { $0.name }
//        if (data.count == 0) {return} else {
//            username = data[0]!
//        }
//    }
//    names is null
    
    var body: some View {
        VStack{
            Text("123,123")
            TextField("用户名", text: $username)
                .padding()
                .background(LightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom,20)
                .onAppear {if (!initname) {
                    initname = true
                    if (names.count != 0) {username = names[0].name!}
                    // Can't put outside Modifying state during view update, this will cause undefined behavior.
                }
                }
            SecureField("密码", text: $password)
                        .padding()
                        .background(LightGreyColor)
                        .cornerRadius(5.0)
                        .padding(.bottom,20)
            if authenticationDidFail {
                Text("用户名或密码错误.")
                    .offset(y:-10)
                    .foregroundColor(.red)
            }
            Button("登录", action: {
                if self.username == "123" && self.password == "123" {
                    let name = UserDefaults(context: self.moc)
                    name.name = self.username
                    name.timestamp = Date.init()
                    try? self.moc.save()
                    self.needLogin.toggle()
                }else{
                    self.authenticationDidFail = true
                }
            })
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(needLogin: .constant(true)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
