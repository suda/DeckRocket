//
//  Presentation.swift
//  DeckRocket
//
//  Created by JP Simard on 6/15/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import UIKit

class Presentation {

    // MARK: Properties

    var markdown = ""
    var slides = [Slide]()

    // MARK: Initializers

    init(pdfPath: String, markdown: String?) {
        let slideImages = UIImage.imagesFromPDFPath(pdfPath)

        var pages = [String]()

        if markdown != nil {
            self.markdown = markdown!
            pages = self.pages()
        }

        for (index, image) in enumerate(slideImages) {
            var page: String?
            if pages.count > index {
                page = pages[index]
            }
            slides.append(Slide(image: image, markdown: page?))
        }
    }

    // MARK: Markdown Parsing

    func pages() -> [String] {
        let locations = pageLocations()

        var pages = [String]()

        for (index, end) in enumerate(locations) {
            var start = 0
            if index > 0 {
                start = locations[index - 1]
            }
            var substring = (markdown as NSString).substringWithRange(NSRange(location: start, length: end-start))
            substring = substring.stringByReplacingOccurrencesOfString("---\n", withString: "")
            pages.append(substring)
        }

        return pages
    }

    func pageLocations() -> [Int] {
        // Pattern must match http://www.decksetapp.com/support/#i-separated-my-content-by-----but-deckset-shows-it-on-one-slide-whats-wrong
        let pattern = "^\\-\\-\\-" // ^\-\-\-
        let pagesExpression = NSRegularExpression(pattern: pattern,
            options: NSRegularExpressionOptions.AnchorsMatchLines,
            error: nil)

        var pageDelimiters = [Int]()

        let range = NSRange(location: 0, length: (markdown as NSString).length)
        if let matches = pagesExpression?.matchesInString(markdown, options: NSMatchingOptions(0), range: range) {
            for match in matches as [NSTextCheckingResult] {
                pageDelimiters.append(match.range.location)
            }
        }

        // EOF is an implicit page delimiter
        pageDelimiters.append(range.length)

        return pageDelimiters
    }
}
