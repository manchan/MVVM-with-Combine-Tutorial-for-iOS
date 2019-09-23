/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import Combine

// 1
class WeeklyWeatherViewModel: ObservableObject, Identifiable {
  // 2
  @Published var city: String = ""
  
  @Published var todaysWeatherEmoji: String = ""

  // 3
  @Published var dataSource: [DailyWeatherRowViewModel] = []

  private let weatherFetcher: WeatherFetchable

  // 4
  private var disposables = Set<AnyCancellable>()

  // 1
  init(
    weatherFetcher: WeatherFetchable,
    scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
  ) {
    self.weatherFetcher = weatherFetcher
    
    // 2
    _ = $city
      // 3
      .dropFirst(1)
      // 4
      .debounce(for: .seconds(0.5), scheduler: scheduler)
      // 5
      .sink(receiveValue: fetchWeather(forCity:))
  }
  
  func fetchWeather(forCity city: String) {
    // 1
    weatherFetcher.weeklyWeatherForecast(forCity: city)
      .map { response in
        // 2
        response.list.map(DailyWeatherRowViewModel.init)
      }

      // 3
      .map(Array.removeDuplicates)

      // 4
      .receive(on: DispatchQueue.main)

      // 5
      .sink(
        receiveCompletion: { [weak self] value in
          guard let self = self else { return }
          switch value {
          case .failure:
            // 6
            self.dataSource = []
            self.todaysWeatherEmoji = ""
          case .finished:
            break
          }
        },
        receiveValue: { [weak self] forecast in
          guard let self = self else { return }
          self.todaysWeatherEmoji = forecast.first?.emoji ?? ""
          // 7
          self.dataSource = forecast
      })

      // 8
      .store(in: &disposables)
  }
}

extension WeeklyWeatherViewModel {
  var currentWeatherView: some View {
    return WeeklyWeatherBuilder.makeCurrentWeatherView(
      withCity: city,
      weatherFetcher: weatherFetcher
    )
  }
}
