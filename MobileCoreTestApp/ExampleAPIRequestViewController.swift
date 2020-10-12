/*
 * Copyright 2019 HM Revenue & Customs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import ios_core_library

class ExampleAPIRequestViewController: UIViewController, CoreNetworkServiceInjected {

    @IBOutlet weak var textViewLog: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewLog.text = ""

        configureNetworkHandlers()
    }

    func configureNetworkHandlers() {
        networkHandler = { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.log("Successfully sent request: \(response)")
            case .failure(let error):
                self.log("Error sending request: \(error)")
            }
        }

        modifyNetworkRequest = {[weak self] request in
            guard let self = self else { return request }
            self.log("Built request: \(request)")
            self.log("All Headers: \(request.allHTTPHeaderFields ?? [:])")
            return request
        }
    }

    func log(_ text: String) {
        let dateAndText = "\(Date())\n\(text)"
        textViewLog.text = [textViewLog.text, dateAndText].filter {!$0.isEmpty}.joined(separator: "\n\n")
    }

    var networkHandler: NetworkHandler!
    var modifyNetworkRequest: ModifyNetworkRequest!

    @IBAction func makeSuccesfulCallTapped(_ sender: UIButton) {
        let requestBuilder = ExampleApiRequestBuilder(
            path: "mobile-version-check",
            method: .post,
            data: ["os": "ios", "version": "6.2.0"],
            headers: ["Accept": "application/vnd.hmrc.1.0+json"]
            )
        //Optionally modify request, here we use this closure just to output the request to the log
        requestBuilder.modifyRequest = modifyNetworkRequest
        self.coreNetworkService.data(request: requestBuilder, networkHandler)
    }

    @IBAction func makeFailingCallTapped(_ sender: UIButton) {
        let requestBuilder = ExampleApiRequestBuilder(
            path: "an/Endpoint",
            method: .get,
            data: ["ExampleKey": "Example Value"],
            headers: ["AHeaderKey": "An Example Value"]
        )
        //Optionally modify request, here we use this closure just to output the request to the log
        requestBuilder.modifyRequest = modifyNetworkRequest
        self.coreNetworkService.data(request: requestBuilder, networkHandler)
    }

    @IBAction func clearLogTapped(_ sender: UIButton) {
        textViewLog.text = ""
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
