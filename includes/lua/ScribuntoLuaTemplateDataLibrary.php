<?php
/**
 * Registers and defines functions to access TemplateData through the Scribunto extension
 *
 * @file
 * @ingroup Extensions
 * @ingroup Scribunto
 *
 * @author Sergey Leschina <mail@putnik.tech>
 * @author John Erling Blad <jeblad@gmail.com>
 */

class ScribuntoLuaTemplateDataLibrary extends Scribunto_LuaLibraryBase {
	public function register() {
		global $wgTemplateDataTime;
		global $wgTemplateDataSize;
		$lib = [
			'loadTemplateData' => [ $this, 'loadTemplateData' ],
		];
		$opts = [
			'time' => $wgTemplateDataTime,
			'size' => $wgTemplateDataSize,
		];

		return $this->getEngine()->registerInterface( __DIR__ . '/TemplateData.lua', $lib, $opts );
	}

	/**
	 * Deep typecast of object to array
	 * @param any $data
	 * @return array
	 */
	private static function castObjectToArray( $data ) {
		if (is_array( $data ) || is_object( $data )) {
			$result = [];
			foreach ($data as $key => $value) {
				$result[$key] = self::castObjectToArray( $value );
			}
			return $result;
		}
		return $data;
	}

	/**
	 * @param string|null $title
	 * @param string|null $langCode
	 * @return array
	 */
	public function loadTemplateData( $title = null, $langCode = null ) {
		$this->checkTypeOptional( 'mw.templatedata.load', 1, $title, 'string', '' );
		$this->checkTypeOptional( 'mw.templatedata.load', 2, $langCode, 'string', '' );
		$this->incrementExpensiveFunctionCount();

		if ( $title === '' ) {
			$title = $this->getParser()->getTitle()->getPrefixedText();
		}

		if ( $langCode === '' ) {
			$langCode = $this->getParser()->getContentLanguage()->getCode();
		}

		$pageTitle = Title::newFromText( $title );
		if ( $pageTitle === null ) {
			return [ null,
				wfMessage( "templatedata-invalid-page-title",
					$title )->text() // don't double escape
			];
		}

		// Mark the source page as a transclusion, so this page gets purged
		// when it changes.
		$this->getParser()->getOutput()->addTemplate( $pageTitle,
			$pageTitle->getArticleID(),
			$pageTitle->getLatestRevID() );

		$dbr = wfGetDB( DB_REPLICA );
		$row = $dbr->selectRow( 'page_props', [ 'pp_value' ], [
			'pp_page' => $pageTitle->getArticleID(),
			'pp_propname' => 'templatedata',
		], __METHOD__ );

		if ( $row === false ) {
			// this should not happen if the JSON is sanitized properly
			return [ null,
				wfMessage( "templatedata-invalid-page-no-templatedata",
					$title )->text() // don't double escape
			];
		}

		$rawData = $row->pp_value;

		$tdb = TemplateDataBlob::newFromDatabase( $rawData );
		$status = $tdb->getStatus();

		if ( !$status->isOK() ) {
			return [ null,
				wfMessage( "templatedata-invalid-page-invalid-templatedata",
					$title,
					$status->getMessage() )->text(), // don't double escape
			];
		}

		$out = self::castObjectToArray( $tdb->getDataInLanguage( $langCode ) );

		if ( is_array( $out['paramOrder'] ) && 0 < count( $out['paramOrder'] ) ) {
			// Re-numbering paramOrder array starting from 1
			$out['paramOrder'] = array_combine(
				range( 1, count( $out['paramOrder'] ) ),
				array_values( $out['paramOrder'] )
			);
		}

		return [ $out ];
	}
}
